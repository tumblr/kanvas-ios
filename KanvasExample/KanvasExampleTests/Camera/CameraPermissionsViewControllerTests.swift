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
    private var controller: CameraPermissionsViewController!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockCameraPermissionsViewControllerDelegate()
    }
    
    override func tearDown() {
        mockDelegate = nil
        controller = nil
        super.tearDown()
    }
    
    func testLoadingViewWithUndeterminedAccessRequestsPermissions() {
        let undeterminedAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .notDetermined,
                                                     initialMicrophoneAccess: .notDetermined)
        loadView(with: undeterminedAuthorizer)
        XCTAssertEqual(undeterminedAuthorizer.mediaAccessRequestsMade, [.video, .audio])
    }
    
    func testLoadingViewWithAuthorizationDoesNotRequestPermissions() {
        let authorizedAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                         initialMicrophoneAccess: .authorized)
        loadView(with: authorizedAuthorizer)
        XCTAssertEqual(authorizedAuthorizer.mediaAccessRequestsMade, [])
    }
    
    func testLoadingViewWithDeniedAuthorizationDoesNotRequestPermissions() {
        let deniedAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied,
                                                           initialMicrophoneAccess: .denied)
        loadView(with: deniedAuthorizer)
        XCTAssertEqual(deniedAuthorizer.mediaAccessRequestsMade, [])
    }
    
    func testLoadingViewWithRestrictedAuthorizationDoesNotRequestPermissions() {
        let restrictedAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .restricted,
                                                               initialMicrophoneAccess: .restricted)
        loadView(with: restrictedAuthorizer)
        XCTAssertEqual(restrictedAuthorizer.mediaAccessRequestsMade, [])
    }
    
    func testLoadingViewWithOneUndeterminedPermissionRequestsThatPermission() {
        let undeterminedCameraAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .notDetermined,
                                                                       initialMicrophoneAccess: .authorized)
        loadView(with: undeterminedCameraAuthorizer)
        XCTAssertEqual(undeterminedCameraAuthorizer.mediaAccessRequestsMade, [.video])
        
        let undeterminedMicAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .restricted,
                                                                    initialMicrophoneAccess: .notDetermined)
        loadView(with: undeterminedMicAuthorizer)
        XCTAssertEqual(undeterminedMicAuthorizer.mediaAccessRequestsMade, [.audio])
    }
    
    func testLoadingViewWithAcceptedPermissionsDoesNotBlockCameraAccess() {
        let authorizedAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                               initialMicrophoneAccess: .authorized)
        loadView(with: authorizedAuthorizer)
        XCTAssertFalse(controller.isViewBlockingCameraAccess)
    }
    
    func testLoadingViewWithDeniedPermissionsBlocksCameraAccess() {
        let restrictedAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied,
                                                               initialMicrophoneAccess: .denied)
        loadView(with: restrictedAuthorizer)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
    
    func testLoadingViewWithCameraOnlyPermissionBlocksCameraAccess() {
        let cameraOnlyAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                               initialMicrophoneAccess: .denied)
        loadView(with: cameraOnlyAuthorizer)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
    
    func testLoadingViewWithMicOnlyPermissionBlocksCameraAccess() {
        let micOnlyAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied,
                                                            initialMicrophoneAccess: .authorized)
        loadView(with: micOnlyAuthorizer)
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
    func loadView(with authorizer: MockCaptureDeviceAuthorizer) {
        controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizer, delegate: mockDelegate)
        controller.loadViewIfNeeded()
        controller.viewWillAppear(false)
    }
}
