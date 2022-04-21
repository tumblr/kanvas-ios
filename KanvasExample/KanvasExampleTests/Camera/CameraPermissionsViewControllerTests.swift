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
    private var mockDelegate: MockCameraPermissionsViewControllerDelegate!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockCameraPermissionsViewControllerDelegate()
    }
    
    override func tearDown() {
        mockDelegate = nil
        super.tearDown()
    }
    
    func testLoadingViewWithUndeterminedAccessRequestsPermissions() {
        let undeterminedAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .notDetermined,
                                                     initialMicrophoneAccess: .notDetermined)
        loadView(with: undeterminedAuthorizer)
        XCTAssertEqual(undeterminedAuthorizer.mediaAccessRequestsMade, [.video, .audio])
    }
    }

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

private extension CameraPermissionsViewControllerTests {
    func loadView(with authorizer: MockCaptureDeviceAuthorizer) {
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizer, delegate: mockDelegate)
        controller.loadViewIfNeeded()
        controller.viewWillAppear(false)
    }
}
