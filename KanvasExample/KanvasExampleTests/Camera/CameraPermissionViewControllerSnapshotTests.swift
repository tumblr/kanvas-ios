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
    private let tolerance: CGFloat = 0.1
    private var mockDelegate: MockCameraPermissionsViewControllerDelegate { MockCameraPermissionsViewControllerDelegate() }

    override func setUp() {
        super.setUp()
        self.recordMode = false
    }
    
    func testViewWithAcceptedPermissionsDoesntAppear() {
        let authorizerMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                         initialMicrophoneAccess: .authorized)
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizerMock, delegate: mockDelegate)
        FBSnapshotVerifyViewController(controller, overallTolerance: tolerance)
    }
    
    func testViewWithNoAccessDisplaysSettingsPrompt() {
        let authorizerMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied,
                                                         initialMicrophoneAccess: .denied)
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizerMock, delegate: mockDelegate)
        FBSnapshotVerifyViewController(controller, overallTolerance: tolerance)
    }
    
    func testViewWithUndeterminedAccessDisplaysSettingsPrompt() {
        let authorizerMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .notDetermined,
                                                         initialMicrophoneAccess: .notDetermined)
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizerMock, delegate: mockDelegate)
        FBSnapshotVerifyViewController(controller, overallTolerance: tolerance)
    }
    
    func testViewWithCameraOnlyAccessDisplaysSettingsPrompt() {
        let authorizedCameraMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                         initialMicrophoneAccess: .notDetermined)
        let cameraOnlyAccessController = CameraPermissionsViewController(captureDeviceAuthorizer: authorizedCameraMock,
                                                                         delegate: mockDelegate)
        FBSnapshotVerifyViewController(cameraOnlyAccessController)
    }
    
    func testViewWithMicrophoneOnlyAccessDisplaysSettingsPrompt() {
        let authorizedMicMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied, initialMicrophoneAccess: .authorized)
        let micOnlyAccessController = CameraPermissionsViewController(captureDeviceAuthorizer: authorizedMicMock,
                                                                      delegate: mockDelegate)
        FBSnapshotVerifyViewController(micOnlyAccessController)
    }
}
