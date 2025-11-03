//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
import Foundation
import XCTest

final class CameraZoomHandlerTests: XCTestCase {

    private let cameraZoomHandlerDelegate = CameraZoomHandlerDelegateStub()

    /// Cameras require actual devices to function
    func newCameraZoomHandler() -> CameraZoomHandler {
        let cameraZoomHandler = CameraZoomHandler()
        cameraZoomHandler.delegate = cameraZoomHandlerDelegate
        return cameraZoomHandler
    }
    
    func testPanZoom() {
        let cameraZoomHandler = newCameraZoomHandler()
        let gesture = UILongPressGestureRecognizer()
        let point = CGPoint(x: 1.0, y: 1.0)
        cameraZoomHandler.setZoom(point: point, gesture: gesture)
        let currentZoom = cameraZoomHandler.currentZoom()
        XCTAssertNil(currentZoom, "Zooming should not be set without device")
    }
    
    func testPinchZoom() {
        let cameraZoomHandler = newCameraZoomHandler()
        let gesture = UIPinchGestureRecognizer()
        gesture.scale = 0.7
        cameraZoomHandler.setZoom(gesture: gesture)
        let currentZoom = cameraZoomHandler.currentZoom()
        XCTAssertNil(currentZoom, "Zooming should not be set without device")
    }
}

/// Stub for testing camera zoom delegate
final class CameraZoomHandlerDelegateStub: CameraZoomHandlerDelegate {
    var currentDeviceForZooming: AVCaptureDevice? {
        return nil
    }
}
