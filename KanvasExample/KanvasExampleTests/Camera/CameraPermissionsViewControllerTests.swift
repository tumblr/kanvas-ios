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
    private var mockAuthorizer: MockCaptureDeviceAuthorizer!
    private var controller: CameraPermissionsViewController!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockCameraPermissionsViewControllerDelegate()
    }
    
    override func tearDown() {
        mockDelegate = nil
        mockAuthorizer = nil
        controller = nil
        super.tearDown()
    }
    
    func testLoadingViewWithUndeterminedAccessRequestsPermissions() {
        loadViewWithPermissions(cameraAccess: .notDetermined, micAccess: .notDetermined)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [.video, .audio])
    }
    
    func testLoadingViewWithAuthorizationDoesNotRequestPermissions() {
        loadViewWithPermissions(cameraAccess: .authorized, micAccess: .authorized)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [])
    }
    
    func testLoadingViewWithDeniedAuthorizationDoesNotRequestPermissions() {
        loadViewWithPermissions(cameraAccess: .denied, micAccess: .denied)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [])
    }
    
    func testLoadingViewWithUndeterminedCameraAccessRequesstsCameraPermission() {
        loadViewWithPermissions(cameraAccess: .notDetermined, micAccess: .authorized)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [.video])
    }
    
    func testLoadingViewWithUndeterminedMicAccessRequestsMicPermission() {
        loadViewWithPermissions(cameraAccess: .authorized, micAccess: .notDetermined)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [.audio])
    }
    
    func testLoadingViewWithAcceptedPermissionsDoesNotBlockCameraAccess() {
        loadViewWithPermissions(cameraAccess: .authorized, micAccess: .authorized)
        XCTAssertFalse(controller.isViewBlockingCameraAccess)
    }
    
    func testLoadingViewWithDeniedPermissionsBlocksCameraAccess() {
        loadViewWithPermissions(cameraAccess: .denied, micAccess: .denied)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
    
    func testLoadingViewWithCameraOnlyPermissionBlocksCameraAccess() {
        loadViewWithPermissions(cameraAccess: .authorized, micAccess: .denied)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
    
    func testLoadingViewWithMicOnlyPermissionBlocksCameraAccess() {
        loadViewWithPermissions(cameraAccess: .denied, micAccess: .authorized)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
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
    func loadViewWithPermissions(cameraAccess: AVAuthorizationStatus, micAccess: AVAuthorizationStatus) {
        mockAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: cameraAccess, initialMicrophoneAccess: micAccess)
        controller = CameraPermissionsViewController(captureDeviceAuthorizer: mockAuthorizer, delegate: mockDelegate)
        controller.loadViewIfNeeded()
        controller.viewWillAppear(false)
    }
}
