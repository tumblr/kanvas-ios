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
        loadViewWithPermissions(initialCameraAccess: .notDetermined, initialMicAccess: .notDetermined)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [.video, .audio])
    }
    
    func testLoadingViewWithAuthorizationDoesNotRequestPermissions() {
        loadViewWithPermissions(initialCameraAccess: .authorized, initialMicAccess: .authorized)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [])
    }
    
    func testLoadingViewWithDeniedAuthorizationDoesNotRequestPermissions() {
        loadViewWithPermissions(initialCameraAccess: .denied, initialMicAccess: .denied)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [])
    }
    
    func testLoadingViewWithUndeterminedCameraAccessRequesstsCameraPermission() {
        loadViewWithPermissions(initialCameraAccess: .notDetermined, initialMicAccess: .authorized)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [.video])
    }
    
    func testLoadingViewWithUndeterminedMicAccessRequestsMicPermission() {
        loadViewWithPermissions(initialCameraAccess: .authorized, initialMicAccess: .notDetermined)
        XCTAssertEqual(mockAuthorizer.mediaAccessRequestsMade, [.audio])
    }
    
    func testLoadingViewWithAcceptedPermissionsDoesNotBlockCameraAccess() {
        loadViewWithPermissions(initialCameraAccess: .authorized, initialMicAccess: .authorized)
        XCTAssertFalse(controller.isViewBlockingCameraAccess)
    }
    
    func testLoadingViewWithDeniedPermissionsBlocksCameraAccess() {
        loadViewWithPermissions(initialCameraAccess: .denied, initialMicAccess: .denied)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
    
    func testLoadingViewWithCameraOnlyPermissionBlocksCameraAccess() {
        loadViewWithPermissions(initialCameraAccess: .authorized, initialMicAccess: .denied)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
    
    func testLoadingViewWithMicOnlyPermissionBlocksCameraAccess() {
        loadViewWithPermissions(initialCameraAccess: .denied, initialMicAccess: .authorized)
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
    
    func testSettingsButtonDisplaysSettings() throws {
        loadViewWithPermissions(initialCameraAccess: .denied, initialMicAccess: .denied)
        let settingsButton = try XCTUnwrap(controller.permissionsView?.settingsButton)
        tap(settingsButton)
        XCTAssertTrue(mockDelegate.appSettingsOpened)
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
    func loadViewWithPermissions(initialCameraAccess: AVAuthorizationStatus,
                                 initialMicAccess: AVAuthorizationStatus,
                                 cameraAccessRequestAnswer: AVAuthorizationStatus = .notDetermined,
                                 micAccessRequestAnswer: AVAuthorizationStatus = .notDetermined) {
        
        mockAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: initialCameraAccess,
                                                     initialMicrophoneAccess: initialMicAccess,
                                                     requestedCameraAccessAnswer: cameraAccessRequestAnswer,
                                                     requestedMicrophoneAccessAnswer: micAccessRequestAnswer)
        
        controller = CameraPermissionsViewController(captureDeviceAuthorizer: mockAuthorizer, delegate: mockDelegate)
        controller.loadViewIfNeeded()
        controller.viewWillAppear(false)
    }
    
    func tap(_ button: UIButton) {
        button.sendActions(for: .touchUpInside)
    }
}
