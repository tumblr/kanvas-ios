//
// Created by Tony Cheng on 8/16/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import Foundation
import XCTest

final class CameraRecorderTests: XCTestCase {

    /// the camera recorder requires a device to run. This is testing the initialization
    func setupCameraRecorder() -> CameraRecorder {
        let size = CGSize(width: 320, height: 480)
        let cameraRecorder = CameraRecorder(size: size,
                photoOutput: nil,
                videoOutput: nil,
                audioOutput: nil,
                recordingDelegate: nil,
                segmentsHandler: CameraSegmentHandlerStub(),
                settings: CameraSettings())
        return cameraRecorder
    }

    /// This test should fail to return an image since it is testing on simulator, but it should always hit the completion block
    func testPhoto() {
        let cameraRecorder = setupCameraRecorder()
        let expectation = XCTestExpectation(description: "photo")
        cameraRecorder.takePhoto(on: .photo, completion: { image in
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5)
    }

    /// This test should fail to return a url since it is testing on simulator, but it should always hit the completion block
    func testGif() {
        let cameraRecorder = setupCameraRecorder()
        let expectation = XCTestExpectation(description: "photo")
        cameraRecorder.takeGifMovie(numberOfFrames: 10, framesPerSecond: 10, completion: { url in
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5)
    }

    /// This test should fail to return a url since it is testing on simulator, but it should always hit the completion block
    func testStopMotion() {
        let mode = CameraMode.stopMotion
        let cameraRecorder = setupCameraRecorder()
        let delegate = CameraRecorderDelegateStub()
        cameraRecorder.recordingDelegate = delegate

        cameraRecorder.startRecordingVideo(on: mode)
        let blockExpectation = XCTestExpectation(description: "block expectation")
        XCTAssert(cameraRecorder.isRecording(), "CameraRecorder failed to start recording")

        cameraRecorder.stopRecordingVideo(completion: { url in
            blockExpectation.fulfill()
            XCTAssert(delegate.videoFinish, "Delegate was not called to finish video")
        })
        wait(for: [blockExpectation], timeout: 5)
    }

    func testDeleteSegment() {
        let cameraRecorder = setupCameraRecorder()
        let segments = createSegments()
        for segment in segments {
            cameraRecorder.addSegment(segment)
        }
        XCTAssert(cameraRecorder.segments().count == segments.count, "Wrong number of segments")
        cameraRecorder.deleteSegment(at: 0, removeFromDisk: false)
        XCTAssert(cameraRecorder.segments().count == segments.count - 1, "CameraRecorder has wrong number of segments after deleting")
    }

    func createSegments() -> [CameraSegment] {
        var segments: [CameraSegment] = []
        if let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let segment = CameraSegment.video(url, MediaInfo(source: .kanvas_camera))

            for _ in 0...5 {
                segments.append(segment)
            }
        }

        return segments
    }

}

/// This mocks up a camera recorder delegate for future classes that require recording segments
final class CameraRecorderDelegateStub: CameraRecordingDelegate {
    func cameraDidTakePhoto(image: UIImage?) -> UIImage? {
        return image
    }

    var videoStart: Bool
    var videoFinish: Bool

    init() {
        videoStart = false
        videoFinish = false
    }

    func photoSettings(for output: AVCapturePhotoOutput?) -> AVCapturePhotoSettings? {
        return nil
    }
    
    func cameraWillTakeVideo() {
        videoStart = true
    }

    func cameraWillFinishVideo() {
        if videoStart {
            videoFinish = true
        }
    }
}
