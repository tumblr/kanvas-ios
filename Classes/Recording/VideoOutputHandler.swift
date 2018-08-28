//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import UIKit

private struct VideoHandlerConstants {
    static let Queue = "VideoQueue"
}

/// A class to handle video recording
final class VideoOutputHandler: NSObject {

    /// start time of the current clip
    private(set) var startTime: CMTime = kCMTimeZero

    /// whether current handler is recording
    private(set) var recording: Bool = false

    private var currentVideoSampleBuffer: CMSampleBuffer?
    private var currentAudioSampleBuffer: CMSampleBuffer?
    private var assetWriter: AVAssetWriter?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var recordedVideoFrameFirst: Bool = false
    private let videoQueue: DispatchQueue = DispatchQueue(label: VideoHandlerConstants.Queue)
    private var finalizing: Bool = false

    // MARK: - external methods

    /// Starts video recording
    ///
    /// - Parameters:
    ///   - assetWriter: the asset writer to append buffers
    ///   - pixelBufferAdaptor: the pixel buffer adapator
    ///   - videoInput: the video input for the asset writer
    ///   - audioInput: the audio input for the asset writer
    func startRecordingVideo(assetWriter: AVAssetWriter?,
                                                pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?,
                                                videoInput: AVAssetWriterInput?,
                                                audioInput: AVAssetWriterInput?) {
        guard let assetWriter = assetWriter, recording == false, finalizing == false else {
            assertionFailure("Should not start record while asset writer is nil or recording is already in progress")
            return
        }

        self.assetWriter = assetWriter
        self.pixelBufferAdaptor = pixelBufferAdaptor
        self.videoInput = videoInput
        self.audioInput = audioInput

        recordedVideoFrameFirst = false
        startTime = CMTime(value: 0, timescale: KanvasCameraTimes.StopMotionFrameTimescale)

        if let sampleBuffer = self.currentVideoSampleBuffer {
            startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        }

        guard let _ = self.assetWriter?.startWriting() else {
            assertionFailure("asset writer couldn't start")
            return
        }
        recording = true

        /// add the first frame if already possible
        if let sampleBuffer = self.currentVideoSampleBuffer {
            processVideoSampleBuffer(sampleBuffer)
        }
    }

    /// Stops recording video and exports as a mp4
    ///
    /// - Parameter completion: success boolean if asset writer completed
    func stopRecordingVideo(completion: @escaping (Bool) -> Void) {
        guard recording && !finalizing else {
            completion(false)
            return
        }

        recording = false
        finalizing = true
        videoQueue.async {
            if let sampleBuffer = self.currentVideoSampleBuffer {
                self.startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            }

            self.videoInput?.markAsFinished()
            self.audioInput?.markAsFinished()
            self.assetWriter?.finishWriting(completionHandler: { [unowned self] in
                self.finalizing = false
                completion(self.assetWriter?.status == .completed && self.assetWriter?.error == nil)
            })
        }
    }

    // MARK: - sample buffer processing
    
    /// The video sample buffer processor
    ///
    /// - Parameter sampleBuffer: The input video sample buffer
    func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        currentVideoSampleBuffer = sampleBuffer
        if recording {
            var newBuffer: CMSampleBuffer? = nil
            CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &newBuffer)
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

    /// The audio buffer processor
    ///
    /// - Parameter sampleBuffer: The input audio sample buffer
    func processAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        currentAudioSampleBuffer = sampleBuffer
        if recording && recordedVideoFrameFirst == true {
            var newBuffer: CMSampleBuffer? = nil
            CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &newBuffer)
            guard let buffer = newBuffer else { return }

            videoQueue.async {
                if self.audioInput?.isReadyForMoreMediaData == true {
                    self.audioInput?.append(buffer)
                }
            }
        }
    }
}
