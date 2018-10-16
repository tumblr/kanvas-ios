//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class CameraInputControllerTests: XCTestCase {

    /// Cameras require actual devices to function; some functions require camera or audio devices but will fail gracefully
    func newCameraInputController() -> CameraInputController {
        let cameraInputController = CameraInputController(settings: CameraSettings(), recorderClass: CameraRecorderStub.self, segmentsHandlerClass: CameraSegmentHandlerStub.self)
        let _ = cameraInputController.view
        return cameraInputController
    }

    func testSwitchCameras() {
        let cameraInputController = newCameraInputController()
        let _ = cameraInputController.switchCameras()
        XCTAssert(cameraInputController.currentCameraPosition == .back, "Simulator should not switch camera")
    }

    func testConfigureMode() {
        let cameraInputController = newCameraInputController()
        do { try? cameraInputController.configureMode(.gif) }
        XCTAssert(cameraInputController.currentCameraOutput == .video, "Gif mode should configure as video")
        do { try? cameraInputController.configureMode(.photo) }
        XCTAssert(cameraInputController.currentCameraOutput == .photo, "Photo mode not configured properly")
    }

    func testTakeGif() {
        let cameraInputController = newCameraInputController()
        cameraInputController.takeGif { (url) in
            XCTAssertNotNil(url, "URL should not be nil")
        }
    }

    func testTakePhoto() {
        let cameraInputController = newCameraInputController()
        cameraInputController.takePhoto(completion: { image in
            XCTAssertNotNil(image, "Image should not be nil")
        })
    }

    func testTakeVideo() {
        let cameraInputController = newCameraInputController()
        let started = cameraInputController.startRecording()
        XCTAssert(started, "Recording should have started")
        cameraInputController.endRecording { (url) in
            XCTAssertNotNil(url, "URL should not be nil")
        }
    }

    func testFlash() {
        let cameraInputController = newCameraInputController()
        XCTAssertEqual(cameraInputController.flashMode, .off, "Flash should be off by default")
        cameraInputController.toggleFlash()
        XCTAssertEqual(cameraInputController.flashMode, .on, "Flash should be toggled on")
    }

    func testZoom() {
        let cameraInputController = newCameraInputController()
        do { try cameraInputController.setZoom(zoomFactor: 0.7) } catch { } // zoom requires device
        let currentZoom = cameraInputController.currentZoom()
        XCTAssertNil(currentZoom, "Zooming should not be set without device")
    }

    func testDeleteSegment() {
        let cameraInputController = newCameraInputController()
        cameraInputController.deleteSegmentAtIndex(0) // testing for graceful failure
        cameraInputController.takePhoto(completion: { (image) in
            XCTAssertEqual(cameraInputController.segments().count, 1, "Photo should be taken")
            cameraInputController.deleteSegmentAtIndex(0)
            XCTAssertEqual(cameraInputController.segments().count, 0, "Photo should be deleted")
        })
    }

    func testMoveSegment() {
        let cameraInputController = newCameraInputController()
        cameraInputController.takePhoto(completion: { (image1) in
            cameraInputController.takePhoto(completion: { (image2) in
                XCTAssertEqual(cameraInputController.segments()[0].image, image1, "Photo should be taken in order")
                cameraInputController.moveSegment(from: 0, to: 1)
                XCTAssertEqual(cameraInputController.segments()[0].image, image2, "Photo order should have been altered")
            })
        })
    }
}
