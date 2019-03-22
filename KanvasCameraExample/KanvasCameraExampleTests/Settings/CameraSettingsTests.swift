//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class CameraSettingsTests: XCTestCase {
    
    // test that the defaults have not changed unexpectedly
    func testDefaultSettings() {
        let settings = CameraSettings()
        
        XCTAssert(settings.enabledModes == [.photo, .gif, .stopMotion], "Expected default settings for camera modes to be enabled.")
        XCTAssert(settings.defaultCameraPositionOption == .back, "Expected camera to open to back position.")
    }
    
    func testEnabledModes() {
        let settings = CameraSettings()
        settings.enabledModes = [.photo]
        settings.defaultMode = .gif
        XCTAssert(settings.defaultMode == .none, "Camera mode should have no default since setting gif is unsupported")
        XCTAssert(settings.enableGifMode == false, "Gif mode should be disabled")
        XCTAssert(settings.enableStopMotionMode == false, "Stop motion mode should be disabled")
    }
    
    func testDefaultCameraPosition() {
        let settings = CameraSettings()
        XCTAssert(settings.defaultCameraPositionOption == .back, "Default mode should be back camera")
    }
    
    func testDefaultFlash() {
        let settings = CameraSettings()
        XCTAssert(settings.preferredFlashOption == .off, "Default flash should be off")
    }

    func testCameraFeatures() {
        let settings = CameraSettings()
        XCTAssertFalse(settings.features.ghostFrame)
        XCTAssertFalse(settings.features.openGLPreview)
        XCTAssertFalse(settings.features.openGLCapture)
        XCTAssertFalse(settings.features.cameraFilters)
        XCTAssertFalse(settings.features.experimentalCameraFilters)
        var features = CameraFeatures()
        features.ghostFrame = true
        features.openGLPreview = true
        features.openGLCapture = true
        features.cameraFilters = true
        XCTAssertTrue(features.ghostFrame)
        XCTAssertTrue(features.openGLPreview)
        XCTAssertTrue(features.openGLCapture)
        XCTAssertTrue(features.cameraFilters)
        XCTAssertFalse(settings.features.experimentalCameraFilters)
    }
    
}
