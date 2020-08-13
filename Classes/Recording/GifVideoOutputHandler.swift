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
    
    private var currentVideoSampleBuffer: CMSampleBuffer?
    private var currentVideoPixelBuffer: CVPixelBuffer?

    private var gifLink: CADisplayLink?
    private var gifBuffers: [CMSampleBuffer] = []
    private var gifPixelBuffers: [CVPixelBuffer] = []
    private var gifFrames: Int = 0
    private var gifCompletion: ((Bool) -> Void)?

    private var assetWriter: AVAssetWriter?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private let shouldUsePixelBuffers: Bool
    private let shouldAddRebound: Bool
    private var framesPerSecond: Int = 0
    private var numberOfFrames: Int = 0

    /// Designated initializer for GifVideoOutputHandler
    ///
    /// - Parameter videoOutput: the video data output that the pixel buffer frames will be coming from. Optional for error handling
    /// - Parameter usePixelBuffer: use the pixel buffer instead of the sample buffer
    required init(videoOutput: AVCaptureVideoDataOutput?, usePixelBuffer: Bool = false, rebound: Bool = true) {
        self.videoOutput = videoOutput
        shouldUsePixelBuffers = usePixelBuffer
        shouldAddRebound = rebound
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
                      numberOfFrames: Int,
                      framesPerSecond: Int,
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
        self.numberOfFrames = numberOfFrames
        self.framesPerSecond = framesPerSecond

        gifFrames = 0
        gifCompletion = completion

        let link = CADisplayLink(target: self, selector: #selector(gifLoop))
        link.preferredFramesPerSecond = framesPerSecond
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
            // TODO remove this `copy()` by not retaining all pixel buffers until recording is over.
            // This copy is required so the pixel buffer pool it came from isn't full.
            guard let buffer = currentVideoPixelBuffer?.copy() else {
                NSLog("returning because current video pixel buffer is nil")
                return
            }
            gifPixelBuffers.append(buffer)
            currentVideoPixelBuffer = nil
            gifFrames += 1
            if gifFrames >= numberOfFrames {
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
                if gifFrames >= numberOfFrames {
                    gifFinishedBursting()
                }
            }
        }
    }

    private func gifFinishedBursting() {
        invalidateLink()

        // the time duration value of each gif frame on export
        let timeValue: CMTimeValue = CMTimeValue(framesPerSecond)

        // the timescale used for each gif frame
        let timeScale: CMTimeScale = Int32(timeValue * Int64(framesPerSecond))

        // frameTime: the composed CMTime from the duration and timescale
        let frameTime: CMTime = CMTimeMake(value: timeValue, timescale: timeScale)

        var nextTime = CMTime(value: 0, timescale: timeScale)
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: nextTime)
        var index = 0

        if shouldUsePixelBuffers {
            if shouldAddRebound {
                gifPixelBuffers = buffersWithReverse(array: gifPixelBuffers)
            }
            self.pixelBufferAdaptor?.assetWriterInput.requestMediaDataWhenReady(on: self.gifQueue, using: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                let pixelBuffer = strongSelf.gifPixelBuffers[index]
                let appendTime = nextTime
                nextTime = CMTimeAdd(nextTime, frameTime)
                strongSelf.pixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: appendTime)
                if index == strongSelf.gifPixelBuffers.count - 1 {
                    strongSelf.videoInput?.markAsFinished()
                    strongSelf.audioInput?.markAsFinished()
                    strongSelf.exportGif(endTime: nextTime)
                }
                else {
                    index += 1
                }
            })
        }
        else {
            if shouldAddRebound {
                gifBuffers = buffersWithReverse(array: gifBuffers)
            }
            self.pixelBufferAdaptor?.assetWriterInput.requestMediaDataWhenReady(on: self.gifQueue, using: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(strongSelf.gifBuffers[index]) else {
                    return
                }
                let appendTime = nextTime
                nextTime = CMTimeAdd(nextTime, frameTime)
                strongSelf.pixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: appendTime)
                if index == strongSelf.gifBuffers.count - 1 {
                    strongSelf.videoInput?.markAsFinished()
                    strongSelf.audioInput?.markAsFinished()
                    strongSelf.exportGif(endTime: nextTime)
                }
                else {
                    index += 1
                }
            })
        }
    }

    private func buffersWithReverse<T>(array: [T]) -> [T] {
        guard array.count > 1 else {
            return array
        }
        let newArray = array + array.reversed().dropFirst().dropLast()

        return newArray
    }

    private func exportGif(endTime: CMTime) {
        assetWriter?.endSession(atSourceTime: endTime)
        gifQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.assetWriter?.finishWriting(completionHandler: {
                strongSelf.recording = false
                strongSelf.gifCompletion?(strongSelf.assetWriter?.status == .completed)
                strongSelf.gifCompletion = nil
                strongSelf.gifBuffers.removeAll()
                strongSelf.gifPixelBuffers.removeAll()
            })
        }
    }

    private func invalidateLink() {
        gifLink?.invalidate()
        gifLink = nil
    }
}
