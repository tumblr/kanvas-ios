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

    func testAcceptingPermissionsUnblocksCameraAccess() {
        loadViewWithPermissions(initialCameraAccess: .notDetermined,
                                initialMicAccess: .notDetermined,
                                cameraAccessRequestAnswer: .authorized,
                                micAccessRequestAnswer: .authorized)
        
        XCTAssertTrue(mockDelegate.cameraPermissionsChangedHasFullAccess)
        XCTAssertFalse(controller.isViewBlockingCameraAccess)
    }
    
    func testDecliningBothPermissionsBlocksCameraAccess() {
        loadViewWithPermissions(initialCameraAccess: .notDetermined,
                                initialMicAccess: .notDetermined,
                                cameraAccessRequestAnswer: .denied,
                                micAccessRequestAnswer: .denied)
        
        XCTAssertFalse(mockDelegate.cameraPermissionsChangedHasFullAccess)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
    
    func testDecliningMicPermissionBlocksCameraAccess() {
        loadViewWithPermissions(initialCameraAccess: .notDetermined,
                                initialMicAccess: .notDetermined,
                                cameraAccessRequestAnswer: .authorized,
                                micAccessRequestAnswer: .denied)
        
        XCTAssertFalse(mockDelegate.cameraPermissionsChangedHasFullAccess)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
    
    func testDecliningCameraPermissionBlockCameraAccess() {
        loadViewWithPermissions(initialCameraAccess: .notDetermined,
                                initialMicAccess: .notDetermined,
                                cameraAccessRequestAnswer: .denied,
                                micAccessRequestAnswer: .authorized)
        
        XCTAssertFalse(mockDelegate.cameraPermissionsChangedHasFullAccess)
        XCTAssertTrue(controller.isViewBlockingCameraAccess)
    }
    
    func testTappingSettingsButtonDisplaysSettings() throws {
        loadViewWithPermissions(initialCameraAccess: .denied, initialMicAccess: .denied)
        let settingsButton = try XCTUnwrap(controller.permissionsView?.settingsButton)
        tap(settingsButton)
        XCTAssertTrue(mockDelegate.appSettingsOpened)
    }

    func testHasFullAccessPropertyIsTrueWhenAccessIsGranted() {
        mockAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                     initialMicrophoneAccess: .authorized)
        controller = CameraPermissionsViewController(captureDeviceAuthorizer: mockAuthorizer, delegate: mockDelegate)
        XCTAssertTrue(controller.hasFullAccess())
    }
    
    func testHasFullAccessPropertyIsFalseWhenAccessIsDenied() {
        mockAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied, initialMicrophoneAccess: .denied)
        controller = CameraPermissionsViewController(captureDeviceAuthorizer: mockAuthorizer, delegate: mockDelegate)
        XCTAssertFalse(controller.hasFullAccess())
    }
    
    func testHasFullAccessIsFalseWithMixedPermissions() {
        mockAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized, initialMicrophoneAccess: .denied)
        controller = CameraPermissionsViewController(captureDeviceAuthorizer: mockAuthorizer, delegate: mockDelegate)
        XCTAssertFalse(controller.hasFullAccess())
        
        mockAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied, initialMicrophoneAccess: .authorized)
        controller = CameraPermissionsViewController(captureDeviceAuthorizer: mockAuthorizer, delegate: mockDelegate)
        XCTAssertFalse(controller.hasFullAccess())
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
