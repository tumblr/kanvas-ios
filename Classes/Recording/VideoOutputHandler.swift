//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for video handlers
protocol VideoOutputHandlerProtocol {
    
    func startRecordingVideo(assetWriter: AVAssetWriter,
                             pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor,
                             audioInput: AVAssetWriterInput?)
    
    func stopRecordingVideo(completion: @escaping (Bool) -> Void)
}

private struct VideoHandlerConstants {
    static let queue = "VideoQueue"
}

/// A class to handle video recording
final class VideoOutputHandler: NSObject, VideoOutputHandlerProtocol {

    /// start time of the current clip
    private(set) var startTime: CMTime = CMTime.zero

    /// whether current handler is recording
    private(set) var recording: Bool = false

    private var currentVideoSampleBuffer: CMSampleBuffer?
    private weak var currentVideoPixelBuffer: CVPixelBuffer?
    private var currentAudioSampleBuffer: CMSampleBuffer?
    private var currentPresentationTime: CMTime?
    private var assetWriter: AVAssetWriter?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var recordedVideoFrameFirst: Bool = false
    private var videoQueue: DispatchQueue = DispatchQueue(label: VideoHandlerConstants.queue)

    // MARK: - external methods

    /// Starts video recording
    ///
    /// - Parameters:
    ///   - assetWriter: the asset writer to append buffers
    ///   - pixelBufferAdaptor: the pixel buffer adapator
    ///   - audioInput: the audio input for the asset writer. This can be nil
    func startRecordingVideo(assetWriter: AVAssetWriter,
                             pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor,
                             audioInput: AVAssetWriterInput?) {
        self.assetWriter = assetWriter
        self.pixelBufferAdaptor = pixelBufferAdaptor
        self.videoInput = pixelBufferAdaptor.assetWriterInput
        self.audioInput = audioInput
        videoQueue = DispatchQueue(label: assetWriter.outputURL.absoluteString)

        recordedVideoFrameFirst = false
        startTime = CMTime(value: 0, timescale: KanvasTimes.stopMotionFrameTimescale)

        if let sampleBuffer = currentVideoSampleBuffer {
            startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        }
        else if let _ = currentVideoPixelBuffer, let presentationTime = currentPresentationTime {
            startTime = presentationTime
        }

        guard assetWriter.startWriting() else {
            assertionFailure("asset writer couldn't start")
            return
        }
        recording = true

        /// add the first frame if already possible
        if let sampleBuffer = currentVideoSampleBuffer {
            processVideoSampleBuffer(sampleBuffer)
        }
        else if let pixelBuffer = currentVideoPixelBuffer, let presentationTime = currentPresentationTime {
            processVideoPixelBuffer(pixelBuffer, presentationTime: presentationTime)
        }
    }

    /// Stops recording video and exports as a mp4
    ///
    /// - Parameter completion: success boolean if asset writer completed
    func stopRecordingVideo(completion: @escaping (Bool) -> Void) {
        guard recording else {
            completion(false)
            return
        }
        recording = false

        if let sampleBuffer = currentVideoSampleBuffer {
            startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        }
        else if let _ = currentVideoPixelBuffer, let presentationTime = currentPresentationTime {
            startTime = presentationTime
        }

        videoInput?.markAsFinished()
        audioInput?.markAsFinished()
        assetWriter?.finishWriting(completionHandler: { [weak self] in
            completion(self?.assetWriter?.status == .completed && self?.assetWriter?.error == nil)
        })
    }

    // MARK: - sample buffer processing
    
    /// The video sample buffer processor
    ///
    /// - Parameter sampleBuffer: The input video sample buffer
    func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        currentVideoSampleBuffer = sampleBuffer
        if recording {
            var newBuffer: CMSampleBuffer? = nil
            CMSampleBufferCreateCopy(allocator: kCFAllocatorDefault, sampleBuffer: sampleBuffer, sampleBufferOut: &newBuffer)
            guard let buffer = newBuffer else { return }

            videoQueue.async {
                if self.videoInput?.isReadyForMoreMediaData == true {
                    if self.recordedVideoFrameFirst == false {
                        self.assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
                        self.recordedVideoFrameFirst = true
                    }
                    self.videoInput?.append(buffer)
                }
            }
        }
    }

    /// The video pixel buffer processor
    ///
    /// - Parameters:
    ///   - pixelBuffer: The filtered pixel buffer input
    ///   - presentationTime: The time to append the buffer
    func processVideoPixelBuffer(_ pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {
        let currentVideoPixelBuffer = pixelBuffer.copy()
        self.currentVideoPixelBuffer = currentVideoPixelBuffer
        currentPresentationTime = presentationTime
        if recording {
            videoQueue.async {
                if self.videoInput?.isReadyForMoreMediaData == true {
                    if self.recordedVideoFrameFirst == false {
                        self.assetWriter?.startSession(atSourceTime: presentationTime)
                        self.recordedVideoFrameFirst = true
                    }
                    self.pixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: presentationTime)
                }
            }
        }
    }

    /// The audio buffer processor
    ///
    /// - Parameter sampleBuffer: The input audio sample buffer
    func processAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        currentAudioSampleBuffer = sampleBuffer
        if recording && recordedVideoFrameFirst == true {
            var newBuffer: CMSampleBuffer? = nil
            CMSampleBufferCreateCopy(allocator: kCFAllocatorDefault, sampleBuffer: sampleBuffer, sampleBufferOut: &newBuffer)
            guard let buffer = newBuffer else { return }

            videoQueue.async {
                if self.audioInput?.isReadyForMoreMediaData == true {
                    self.audioInput?.append(buffer)
                }
            }
        }
    }
    
    /// Gets the current clip duration, if recording. otherwise it is nil
    ///
    /// - Returns: time interval in seconds of the current clip
    func currentClipDuration() -> TimeInterval? {
        guard recording, let currentVideoSample = currentVideoSampleBuffer else { return nil }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(currentVideoSample)
        let difference = CMTimeSubtract(timestamp, startTime)
        return CMTimeGetSeconds(difference)
    }

    func assetWriterURL() -> URL? {
        return assetWriter?.outputURL
    }
}
