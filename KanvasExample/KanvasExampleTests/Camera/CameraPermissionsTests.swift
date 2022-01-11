//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@testable import Kanvas
import FBSnapshotTestCase
import XCTest
import AVFoundation

final class MockCaptureDeviceAuthorizer: CaptureDeviceAuthorizing {

    var currentCameraAccess: AVAuthorizationStatus
    var currentMicrophoneAccess: AVAuthorizationStatus
    let requestedCameraAccessAnswer: AVAuthorizationStatus
    let requestedMicrophoneAccessAnswer: AVAuthorizationStatus

    init(initialCameraAccess: AVAuthorizationStatus, initialMicrophoneAccess: AVAuthorizationStatus, requestedCameraAccessAnswer: AVAuthorizationStatus, requestedMicrophoneAccessAnswer: AVAuthorizationStatus) {
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
        let controller = CameraPermissionsViewController(shouldShowMediaPicker: true, captureDeviceAuthorizer: authorizer)
        controller.delegate = delegate
        controller.cameraAccessButtonPressed()
        XCTAssertEqual(delegate.cameraPermissionsChangedHasFullAccess, false)
        controller.microphoneAccessButtonPressed()
        XCTAssertEqual(delegate.cameraPermissionsChangedHasFullAccess, true)
    }

    func testMediaPickerButtonPressed() {
        let authorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .notDetermined, initialMicrophoneAccess: .notDetermined, requestedCameraAccessAnswer: .authorized, requestedMicrophoneAccessAnswer: .denied)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let controller = CameraPermissionsViewController(shouldShowMediaPicker: true, captureDeviceAuthorizer: authorizer)
        controller.delegate = delegate
        controller.mediaPickerButtonPressed()
        XCTAssertEqual(delegate.mediaPickerButtonTapped, true)
    }

    func testHasFullAccess() {
        let authorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized, initialMicrophoneAccess: .authorized, requestedCameraAccessAnswer: .authorized, requestedMicrophoneAccessAnswer: .authorized)
        let controller = CameraPermissionsViewController(shouldShowMediaPicker: true, captureDeviceAuthorizer: authorizer)
        XCTAssertEqual(controller.hasFullAccess(), true)
    }

    func testOpenAppSettingsWhenAccessIsAlreadyDenied() {
        let authorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied, initialMicrophoneAccess: .denied, requestedCameraAccessAnswer: .denied, requestedMicrophoneAccessAnswer: .denied)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let controller = CameraPermissionsViewController(shouldShowMediaPicker: true, captureDeviceAuthorizer: authorizer)
        controller.delegate = delegate
        controller.cameraAccessButtonPressed()
        XCTAssertEqual(delegate.appSettingsOpened, true)
    }

}

final class CameraPermissionsViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func testViewWithNoAccess() {
        let view = CameraPermissionsView(showMediaPicker: true, frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        view.layoutIfNeeded()
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }

    func testViewWithCameraAccess() {
        let view = CameraPermissionsView(showMediaPicker: true, frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        view.updateCameraAccess(hasAccess: true)
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }

    func testViewWithMicrophoneAccess() {
        let view = CameraPermissionsView(showMediaPicker: true, frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        view.updateMicrophoneAccess(hasAccess: true)
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }

    func testViewWithCameraAndMicrophoneAccess() {
        let view = CameraPermissionsView(showMediaPicker: true, frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        view.updateCameraAccess(hasAccess: true)
        view.updateMicrophoneAccess(hasAccess: true)
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }

    func testViewWithoutMediaPickerButton() {
        let view = CameraPermissionsView(showMediaPicker: false, frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }

}
