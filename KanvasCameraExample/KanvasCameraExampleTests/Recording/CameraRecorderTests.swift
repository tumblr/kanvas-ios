//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import AVFoundation
import XCTest

/// This mocks up a camera recorder for future classes that require recording segments

final class CameraRecorderTests: XCTestCase {

    /// the camera recorder requires a device to run. This is testing the initialization
    func setupCameraRecorder() -> CameraRecorder {
        let size = CGSize(width: 320, height: 480)
        let cameraRecorder = CameraRecorder(size: size,
                photoOutput: nil,
                videoOutput: nil,
                audioOutput: nil,
                recordingDelegate: nil)
        return cameraRecorder
    }

    /// This test should fail to return an image since it is testing on simulator, but it should always hit the completion block
    func testPhoto() {
        let cameraRecorder = setupCameraRecorder()
        let expectation = XCTestExpectation(description: "photo")
        cameraRecorder.takePhoto(completion: { image in
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5)
    }

    /// This test should fail to return a url since it is testing on simulator, but it should always hit the completion block
    func testGif() {
        let cameraRecorder = setupCameraRecorder()
        let expectation = XCTestExpectation(description: "photo")
        cameraRecorder.takeGifMovie(completion: { url in
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5)
    }

    /// This test should fail to return a url since it is testing on simulator, but it should always hit the completion block
    func testStopMotion() {
        let cameraRecorder = setupCameraRecorder()
        let delegate = CameraRecorderDelegateStub()
        cameraRecorder.recordingDelegate = delegate

        let blockExpectation = XCTestExpectation(description: "blockExpectation")
        let started = cameraRecorder.startRecordingVideo()
        XCTAssert(started, "CameraRecorder failed to start recording")

        cameraRecorder.stopRecordingVideo(completion: { url in
            blockExpectation.fulfill()
        })
        wait(for: [delegate.videoStartExpectation, delegate.videoFinishExpectation, blockExpectation], timeout: 5)
    }

    func testDeleteSegment() {
        let cameraRecorder = setupCameraRecorder()
        let segments = createSegments()
        for segment in segments {
            cameraRecorder.addSegment(segment)
        }
        XCTAssert(cameraRecorder.segments().count == segments.count, "Wrong number of segments")
        cameraRecorder.deleteSegmentAtIndex(0, removeFromDisk: false)
        XCTAssert(cameraRecorder.segments().count == segments.count - 1, "CameraRecorder has wrong number of segments after deleting")
    }

    func createSegments() -> [CameraSegment] {
        var segments: [CameraSegment] = []
        if let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let segment = CameraSegment.video(url)

            for _ in 0...5 {
                segments.append(segment)
            }
        }

        return segments
    }

}

final class CameraRecorderDelegateStub: CameraRecordingDelegate {
    var videoStartExpectation: XCTestExpectation
    var videoFinishExpectation: XCTestExpectation

    init() {
        videoStartExpectation = XCTestExpectation(description: "start")
        videoFinishExpectation = XCTestExpectation(description: "finish")
    }

    func photoSettingsForCamera() -> AVCapturePhotoSettings? {
        return nil
    }

    func cameraWillTakeVideo() {
        videoStartExpectation.fulfill()
    }

    func cameraWillFinishVideo() {
        videoFinishExpectation.fulfill()
    }
}
