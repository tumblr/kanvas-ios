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
    private var mockDelegate: MockCameraPermissionsViewControllerDelegate { MockCameraPermissionsViewControllerDelegate() }

    override func setUp() {
        super.setUp()
        self.recordMode = false
    }
    
    func testViewWithAcceptedPermissionsDoesntAppear() {
        let authorizerMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                         initialMicrophoneAccess: .authorized)
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizerMock, delegate: mockDelegate)
        FBSnapshotArchFriendlyVerifyViewController(controller)
    }
    
    func testViewWithNoAccessDisplaysSettingsPrompt() {
        let authorizerMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied,
                                                         initialMicrophoneAccess: .denied)
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizerMock, delegate: mockDelegate)
        FBSnapshotArchFriendlyVerifyViewController(controller)
    }
    
    func testViewWithUndeterminedAccessDisplaysSettingsPrompt() {
        let authorizerMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .notDetermined,
                                                         initialMicrophoneAccess: .notDetermined)
        let controller = CameraPermissionsViewController(captureDeviceAuthorizer: authorizerMock, delegate: mockDelegate)
        FBSnapshotArchFriendlyVerifyViewController(controller)
    }
    
    func testViewWithCameraOnlyAccessDisplaysSettingsPrompt() {
        let authorizedCameraMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized,
                                                         initialMicrophoneAccess: .notDetermined)
        let cameraOnlyAccessController = CameraPermissionsViewController(captureDeviceAuthorizer: authorizedCameraMock,
                                                                         delegate: mockDelegate)
        FBSnapshotArchFriendlyVerifyViewController(cameraOnlyAccessController)
    }
    
    func testViewWithMicrophoneOnlyAccessDisplaysSettingsPrompt() {
        let authorizedMicMock = MockCaptureDeviceAuthorizer(initialCameraAccess: .denied, initialMicrophoneAccess: .authorized)
        let micOnlyAccessController = CameraPermissionsViewController(captureDeviceAuthorizer: authorizedMicMock,
                                                                      delegate: mockDelegate)
        FBSnapshotArchFriendlyVerifyViewController(micOnlyAccessController)
    }
}

fileprivate let defaultArm64CompatiblePerPixelTolerance: CGFloat = 0.02
fileprivate let defaultArm64CompatibleOverallTolerance: CGFloat = 0.005

private extension FBSnapshotTestCase {
    func FBSnapshotArchFriendlyVerifyViewController(_ viewController: UIViewController,
                                                    perPixelTolerance: CGFloat = defaultArm64CompatiblePerPixelTolerance,
                                                    overallTolerance:CGFloat = defaultArm64CompatibleOverallTolerance) {
        FBSnapshotVerifyViewController(viewController, perPixelTolerance: perPixelTolerance, overallTolerance: overallTolerance)
    }
}
