//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

private struct GifHandlerConstants {
    static let queue = "GifQueue"
}

/// A handler for recording videos in the gif (forwards then backwards) method
final class GifVideoOutputHandler: NSObject {

    // bool for whether the handler is currently in a recording state
    private(set) var recording = false

    private let gifQueue = DispatchQueue(label: GifHandlerConstants.queue)
    private let videoOutput: AVCaptureVideoDataOutput?
    
    private weak var currentVideoSampleBuffer: CMSampleBuffer?
    private var currentVideoPixelBuffer: CVPixelBuffer? // todo jimmy weak too?

    private var gifLink: CADisplayLink?
    private var gifBuffers: [CMSampleBuffer] = []
    private var gifPixelBuffers: [CVPixelBuffer] = []
    private var gifFrames: Int = 0
    private var gifCompletion: ((Bool) -> Void)?
    private var maxGifFrames = KanvasCameraTimes.gifTotalFrames

    private var assetWriter: AVAssetWriter?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private let shouldUsePixelBuffers: Bool

    /// Designated initializer for GifVideoOutputHandler
    ///
    /// - Parameter videoOutput: the video data output that the pixel buffer frames will be coming from. Optional for error handling
    required init(videoOutput: AVCaptureVideoDataOutput?, usePixelBuffer: Bool = false) {
        self.videoOutput = videoOutput
        shouldUsePixelBuffers = usePixelBuffer
    }

    // MARK: - external methods
    
    /// Starts capturing frames for creating a gif video
    ///
    /// - Parameters:
    ///   - assetWriter: The asset writer to append buffers to
    ///   - pixelBufferAdaptor: The pixel buffer adaptor that is attached to the asset writer
    ///   - videoInput: Video input for pixel buffer adaptor
    ///   - audioInput: Audio input for the asset writer. Is necessary since the asset writer setup is the same
    ///   - longerDuration: Bool for determining duration length
    ///   - completion: returns a success boolean
    func takeGifMovie(assetWriter: AVAssetWriter?,
                      pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?,
                      videoInput: AVAssetWriterInput?,
                      audioInput: AVAssetWriterInput?,
                      longerDuration: Bool = false,
                      completion: @escaping (Bool) -> Void) {

        guard !recording else {
            completion(false)
            return
        }

        recording = true
        self.assetWriter = assetWriter
        self.pixelBufferAdaptor = pixelBufferAdaptor
        self.videoInput = videoInput
        self.audioInput = audioInput
        if longerDuration {
            maxGifFrames = 2 * KanvasCameraTimes.gifTotalFrames
        }
        else {
            maxGifFrames = KanvasCameraTimes.gifTotalFrames
        }

        gifFrames = 0
        gifCompletion = completion

        let link = CADisplayLink(target: self, selector: #selector(gifLoop))
        link.preferredFramesPerSecond = KanvasCameraTimes.gifPreferredFramesPerSecond
        link.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        gifLink = link
    }

    /// Cancels the current frame loops and invalidates the display link
    func cancelGif() {
        invalidateLink()
        gifCompletion?(false)
        gifCompletion = nil
        recording = false
    }

    // MARK: - sample buffer processing

    /// Helper method for processing frames
    ///
    /// - Parameter sampleBuffer: the video CMSampleBuffer
    func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        currentVideoSampleBuffer = sampleBuffer
    }

    /// Helper method for processing pixel buffer frames
    ///
    /// - Parameter pixelBuffer: the video CVPixelBuffer
    func processVideoPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        currentVideoPixelBuffer = pixelBuffer
    }

    // MARK: - private helper methods

     @objc private func gifLoop() {
        guard videoOutput != nil else {
            cancelGif()
            return
        }
        if shouldUsePixelBuffers {
            guard let buffer = currentVideoPixelBuffer?.copy() else {
                NSLog("returning because current video pixel buffer is nil")
                return
            }
            gifPixelBuffers.append(buffer)
            gifFrames += 1
            if gifFrames >= KanvasCameraTimes.gifTotalFrames {
                gifFinishedBursting()
            }
    }
        else {
            guard let buffer = currentVideoSampleBuffer else {
                // current video sample buffer may not be set yet, so don't necessarily cancelGif
                return
            }
            // we need to create a copy of the CMSampleBuffer, the other one will be automatically reused by the video data output
            var newBuffer: CMSampleBuffer? = nil
            CMSampleBufferCreateCopy(allocator: kCFAllocatorDefault, sampleBuffer: buffer, sampleBufferOut: &newBuffer)
            if let buffer = newBuffer {
                gifBuffers.append(buffer)
                gifFrames += 1
                if gifFrames >= KanvasCameraTimes.gifTotalFrames {
                    gifFinishedBursting()
                }
            }
        }
    }

    private func gifFinishedBursting() {
        invalidateLink()

        var nextTime = CMTime(value: 0, timescale: KanvasCameraTimes.gifTimeScale)
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: nextTime)
        var index = 0

        if shouldUsePixelBuffers {
            gifPixelBuffers = buffersWithReverse(array: gifPixelBuffers)
            self.pixelBufferAdaptor?.assetWriterInput.requestMediaDataWhenReady(on: self.gifQueue, using: { [unowned self] in
                let pixelBuffer = self.gifPixelBuffers[index]
                let appendTime = nextTime
                nextTime = CMTimeAdd(nextTime, KanvasCameraTimes.gifFrameTime)
                self.pixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: appendTime)
                if index == self.gifPixelBuffers.count - 1 {
                    self.videoInput?.markAsFinished()
                    self.audioInput?.markAsFinished()
                    self.exportGif(endTime: nextTime)
                }
                else {
                    index += 1
                }
            })
        }
        else {
            gifBuffers = buffersWithReverse(array: gifBuffers)
            self.pixelBufferAdaptor?.assetWriterInput.requestMediaDataWhenReady(on: self.gifQueue, using: { [unowned self] in
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(self.gifBuffers[index]) else {
                    return
                }
                let appendTime = nextTime
                nextTime = CMTimeAdd(nextTime, KanvasCameraTimes.gifFrameTime)
                self.pixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: appendTime)
                if index == self.gifBuffers.count - 1 {
                    self.videoInput?.markAsFinished()
                    self.audioInput?.markAsFinished()
                    self.exportGif(endTime: nextTime)
                }
                else {
                    index += 1
                }
            })
        }
    }

    private func buffersWithReverse<T>(array: [T]) -> [T] {
        guard array.count > 1 else {
            NSLog("array needs to be at least two elements to reverse")
            return array
        }
        let newArray = array + Array(array.reversed()[1...array.count - 2])

        return newArray
    }

    private func exportGif(endTime: CMTime) {
        assetWriter?.endSession(atSourceTime: endTime)
        gifQueue.async { [unowned self] in
            self.assetWriter?.finishWriting(completionHandler: {
                self.recording = false
                self.gifCompletion?(self.assetWriter?.status == .completed)
                self.gifCompletion = nil
                self.gifBuffers.removeAll()
                self.gifPixelBuffers.removeAll()
            })
        }
    }

    private func invalidateLink() {
        gifLink?.invalidate()
        gifLink = nil
    }
}
