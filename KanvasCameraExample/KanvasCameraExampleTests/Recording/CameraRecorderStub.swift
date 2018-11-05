//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import AVFoundation
import Foundation
import UIKit

final class CameraRecorderStub: CameraRecordingProtocol {

    private var recording = false
    private var currentVideoSample: CMSampleBuffer?
    private var cameraSegmentHandler: SegmentsHandlerType
    private var startTime: Date?
    var recordingDelegate: CameraRecordingDelegate? = nil

    required init(size: CGSize, photoOutput: AVCapturePhotoOutput?, videoOutput: AVCaptureVideoDataOutput?, audioOutput: AVCaptureAudioDataOutput?, recordingDelegate: CameraRecordingDelegate?, segmentsHandler: SegmentsHandlerType) {
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

    func startRecordingVideo() {
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
                cameraSegmentHandler.addNewVideoSegment(url: url)
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

    func takePhoto(completion: @escaping (UIImage?) -> Void) {
        if isRecording() {
            completion(nil)
            return
        }
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            cameraSegmentHandler.addNewImageSegment(image: image, size: image.size, completion: { (success, segment) in
                completion(image)
            })
        }
        else {
            NSLog("image not loaded")
            completion(nil)
        }
    }

    func exportRecording(completion: @escaping (URL?) -> Void) {
        cameraSegmentHandler.exportVideo(completion: { url in
            completion(url)
            self.recording = false
        })
    }

    func deleteSegmentAtIndex(_ index: Int, removeFromDisk: Bool = false) {
        if isRecording() {
            return
        }
        cameraSegmentHandler.deleteSegment(index: index, removeFromDisk: false)
    }
    
    func moveSegment(from originIndex: Int, to destinationIndex: Int) {
        cameraSegmentHandler.moveSegment(from: originIndex, to: destinationIndex)
    }
    
    func takeGifMovie(completion: @escaping (URL?) -> Void) {
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

    func processAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {

    }

    func currentClipDuration() -> TimeInterval? {
        guard let startTime = startTime, isRecording() else { return nil }
        return Date().timeIntervalSince(startTime)
    }
}
