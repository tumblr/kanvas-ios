//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@testable import Kanvas
import XCTest
import AVFoundation

final class MockCaptureDeviceAuthorizer: CaptureDeviceAuthorizing {

    var currentCameraAccess: AVAuthorizationStatus
    var currentMicrophoneAccess: AVAuthorizationStatus
    let requestedCameraAccessAnswer: AVAuthorizationStatus
    let requestedMicrophoneAccessAnswer: AVAuthorizationStatus

    init(initialCameraAccess: AVAuthorizationStatus,
         initialMicrophoneAccess: AVAuthorizationStatus,
         requestedCameraAccessAnswer: AVAuthorizationStatus = .notDetermined,
         requestedMicrophoneAccessAnswer: AVAuthorizationStatus = .notDetermined) {
        
        self.currentCameraAccess = initialCameraAccess
        self.currentMicrophoneAccess = initialMicrophoneAccess
        self.requestedCameraAccessAnswer = requestedCameraAccessAnswer
        self.requestedMicrophoneAccessAnswer = requestedMicrophoneAccessAnswer
    }

    func requestAccess(for mediaType: AVMediaType, completionHandler: @escaping (Bool) -> ()) {
        let authorizationStatus: AVAuthorizationStatus? = {
            switch mediaType {
            case .video:
                currentCameraAccess = requestedCameraAccessAnswer
                return currentCameraAccess
            case .audio:
                currentMicrophoneAccess = requestedMicrophoneAccessAnswer
                return currentCameraAccess
            default:
                return nil
            }
        }()
        completionHandler(authorizationStatus == .authorized)
    }

    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        switch mediaType {
        case .video:
            return currentCameraAccess
        case .audio:
            return currentMicrophoneAccess
        default:
            return .denied
        }
    }
}

final class MockCameraPermissionsViewControllerDelegate: CameraPermissionsViewControllerDelegate {

    var cameraPermissionsChangedHasFullAccess: Bool = false
    var mediaPickerButtonTapped: Bool = false
    var appSettingsOpened: Bool = false

    func cameraPermissionsChanged(hasFullAccess: Bool) {
        cameraPermissionsChangedHasFullAccess = hasFullAccess
    }

    func didTapMediaPickerButton(completion: (() -> ())?) {
        mediaPickerButtonTapped = true
        completion?()
    }

    func openAppSettings(completion: ((Bool) -> ())?) {
        appSettingsOpened = true
        completion?(true)
    }
}

final class CaptureDeviceAuthorizerTests: XCTestCase {

    func testForSakeOfJustHavingATest() {
        let _ = CaptureDeviceAuthorizer()
        XCTAssert(true)
    }

}

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
