//
// Created by Tony Cheng on 8/15/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class CameraSettingsTests: XCTestCase {
    
    // test that the defaults have not changed unexpectedly
    func testDefaultSettings() {
        let settings = CameraSettings()
        
        XCTAssert(settings.enabledModes == [.photo, .loop, .stopMotion], "Expected default settings for camera modes to be enabled.")
        XCTAssert(settings.defaultCameraPositionOption == .back, "Expected camera to open to back position.")
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
