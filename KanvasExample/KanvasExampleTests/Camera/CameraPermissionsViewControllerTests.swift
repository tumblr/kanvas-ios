//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@testable import Kanvas
import XCTest
import AVFoundation

final class CameraPermissionsViewControllerTests: XCTestCase {

    func testChangeCameraPermissions() {
        let authorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .notDetermined, initialMicrophoneAccess: .notDetermined, requestedCameraAccessAnswer: .authorized, requestedMicrophoneAccessAnswer: .authorized)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizer, delegate: delegate)
        controller.requestCameraAccess()
        XCTAssertEqual(delegate.cameraPermissionsChangedHasFullAccess, false)
        controller.requestMicrophoneAccess()
        XCTAssertEqual(delegate.cameraPermissionsChangedHasFullAccess, true)
    }

    func testHasFullAccess() {
        let authorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized, initialMicrophoneAccess: .authorized, requestedCameraAccessAnswer: .authorized, requestedMicrophoneAccessAnswer: .authorized)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizer, delegate: delegate)
        XCTAssertEqual(controller.hasFullAccess(), true)
    }

    func testOpenAppSettingsWhenAccessIsAlreadyDenied() {
        let authorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied, initialMicrophoneAccess: .denied, requestedCameraAccessAnswer: .denied, requestedMicrophoneAccessAnswer: .denied)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizer, delegate: delegate)
        controller.loadViewIfNeeded()
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
}
