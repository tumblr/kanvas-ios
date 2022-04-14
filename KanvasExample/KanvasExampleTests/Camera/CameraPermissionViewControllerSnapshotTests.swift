//
//  CameraPermissionsViewControllerSnapshotTests.swift
//  KanvasExampleTests
//
//  Created by Declan McKenna on 07/04/2022.
//  Copyright © 2022 Tumblr. All rights reserved.
//

@testable import Kanvas
import XCTest
import FBSnapshotTestCase

final class CameraPermissionsViewControllerSnapshotTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        self.recordMode = false
    }
    
    func testViewWithAcceptedPermissionsDoesntAppear() {
        let authorizerMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                         initialMicrophoneAccess: .authorized)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizerMock)
        controller.delegate = delegate
        FBSnapshotVerifyViewController(controller)
    }
    
    func testViewWithNoAccessDisplaysSettingsPrompt() {
        let authorizerMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied,
                                                         initialMicrophoneAccess: .denied)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizerMock)
        controller.delegate = delegate
        FBSnapshotVerifyViewController(controller)
    }
    
    func testViewWithUndeterminedAccessDisplaysSettingsPrompt() {
        let authorizerMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .notDetermined,
                                                         initialMicrophoneAccess: .notDetermined)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizerMock)
        controller.delegate = delegate
        FBSnapshotVerifyViewController(controller)
    }
    
    func testViewWithCameraOnlyAccessDisplaysSettingsPrompt() {
        let authorizedCameraMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                         initialMicrophoneAccess: .notDetermined)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let cameraOnlyAccessController = CameraPermissionsViewController(captureDeviceAuthorizer: authorizedCameraMock)
        cameraOnlyAccessController.delegate = delegate
        FBSnapshotVerifyViewController(cameraOnlyAccessController)
    }
    
    func testViewWithMicrophoneOnlyAccessDisplaysSettingsPrompt() {
        let authorizedMicMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied, initialMicrophoneAccess: .authorized)
        let delegate = MockCameraPermissionsViewControllerDelegate()
        let micOnlyAccessController = CameraPermissionsViewController(captureDeviceAuthorizer: authorizedMicMock)
        micOnlyAccessController.delegate = delegate
        FBSnapshotVerifyViewController(micOnlyAccessController)
    }
}
