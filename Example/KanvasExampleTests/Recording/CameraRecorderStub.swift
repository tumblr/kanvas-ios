//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
import Foundation
import UIKit

final class CameraRecorderStub: CameraRecordingProtocol {

    private var recording = false
    private var currentVideoSample: CMSampleBuffer?
    private var cameraSegmentHandler: SegmentsHandlerType
    private var startTime: Date?
    var recordingDelegate: CameraRecordingDelegate? = nil

    required init(size: CGSize, photoOutput: AVCapturePhotoOutput?, videoOutput: AVCaptureVideoDataOutput?, audioOutput: AVCaptureAudioDataOutput?, recordingDelegate: CameraRecordingDelegate?, segmentsHandler: SegmentsHandlerType, settings: CameraSettings) {
        self.recordingDelegate = recordingDelegate
        self.cameraSegmentHandler = segmentsHandler
    }

    func addSegment(_ segment: CameraSegment) {
        cameraSegmentHandler.addSegment(segment)
    }

    func isRecording() -> Bool {
        return recording
    }

    func segments() -> [CameraSegment] {
        return cameraSegmentHandler.segments
    }

    func outputURL() -> URL? {
        return nil
    }

    func startRecordingVideo(on mode: CameraMode) {
        if isRecording() {
            return
        }
        recording = true
        startTime = Date()
    }

    func stopRecordingVideo(completion: @escaping (URL?) -> Void) {
        if isRecording() {
            recording = false
            if let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
                let mediaInfo = MediaInfo(source: .kanvas_camera)
                cameraSegmentHandler.addNewVideoSegment(url: url, mediaInfo: mediaInfo)
                completion(url)
            }
            else {
                NSLog("mp4 not loaded")
                completion(nil)
            }
        }
        else {
            NSLog("mp4 not loaded")
            completion(nil)
        }
    }

    func cancelRecording() {
        recording = false
    }

    func takePhoto(on mode: CameraMode, cameraPosition: AVCaptureDevice.Position? = .back, completion: @escaping (UIImage?) -> Void) {
        if isRecording() {
            completion(nil)
            return
        }
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            cameraSegmentHandler.addNewImageSegment(image: image, size: image.size, mediaInfo: mediaInfo, completion: { (success, segment) in
                completion(image)
            })
        }
        else {
            NSLog("image not loaded")
            completion(nil)
        }
    }

    func exportRecording(completion: @escaping (URL?, MediaInfo?) -> Void) {
        cameraSegmentHandler.exportVideo(completion: { url, mediaInfo in
            completion(url, mediaInfo)
            self.recording = false
        })
    }

    func deleteSegment(at index: Int, removeFromDisk: Bool = false) {
        if isRecording() {
            return
        }
        cameraSegmentHandler.deleteSegment(at: index, removeFromDisk: false)
    }

    func deleteAllSegments(removeFromDisk: Bool) {
        while cameraSegmentHandler.segments.count > 0 {
            cameraSegmentHandler.deleteSegment(at: 0, removeFromDisk: removeFromDisk)
        }
    }

    func moveSegment(from originIndex: Int, to destinationIndex: Int) {
        cameraSegmentHandler.moveSegment(from: originIndex, to: destinationIndex)
    }
    
    func takeGifMovie(numberOfFrames: Int, framesPerSecond: Int, completion: @escaping (URL?) -> Void) {
        if isRecording() {
            completion(nil)
            return
        }
        recording = true
        if let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            completion(url)
        }
        else {
            completion(nil)
        }
        recording = false
    }

    func reset() {
        if !isRecording() {
            cameraSegmentHandler.reset(removeFromDisk: false)
        }
    }

    func updateOutputSize(_ size: CGSize) {

    }

    func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        currentVideoSample = sampleBuffer
    }

    func processVideoPixelBuffer(_ pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {

    }

    func processAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {

    }

    func currentClipDuration() -> TimeInterval? {
        guard let startTime = startTime, isRecording() else { return nil }
        return Date().timeIntervalSince(startTime)
    }
}
