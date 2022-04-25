//
//  MockCameraPermissionsViewControllerDelegate.swift
//  KanvasExampleTests
//
//  Created by Declan McKenna on 21/04/2022.
//  Copyright © 2022 Tumblr. All rights reserved.
//

@testable import Kanvas

final class MockCameraPermissionsViewControllerDelegate: CameraPermissionsViewControllerDelegate {

    var cameraPermissionsChangedHasFullAccess: Bool = false
    var mediaPickerButtonTapped: Bool = false
    var appSettingsOpened: Bool = false

    func cameraPermissionsChanged(hasFullAccess: Bool) {
        cameraPermissionsChangedHasFullAccess = hasFullAccess
    }

    func openAppSettings(completion: ((Bool) -> ())?) {
        appSettingsOpened = true
        completion?(true)
    }
}
