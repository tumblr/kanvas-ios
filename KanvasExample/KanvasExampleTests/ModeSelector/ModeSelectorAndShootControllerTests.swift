//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ModeSelectorAndShootControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> ModeSelectorAndShootController {
        let settings = CameraSettings()
        settings.enabledModes = [.stopMotion, .photo, .loop]
        let viewController = ModeSelectorAndShootController(settings: settings)
        viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return viewController
    }

    func newDelegateStub() -> ModeSelectorAndShootDelegateStub {
        let stub = ModeSelectorAndShootDelegateStub()
        return stub
    }

    func testShowMode() {
        let viewController = newViewController()
        viewController.showModeButton()
        FBSnapshotVerifyView(viewController.view, tolerance: 0.05)
    }

    func testHideMode() {
        let viewController = newViewController()
        viewController.hideModeButton()
        FBSnapshotVerifyView(viewController.view)
    }

    func testSetMode() {
        let viewController = newViewController()
        UIView.setAnimationsEnabled(false)
        viewController.setMode(.stopMotion, from: .loop)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view, tolerance: 0.05)
    }

    func testModeTap() {
        let viewController = newViewController()
        viewController.delegate = newDelegateStub()
        viewController.modeButtonViewDidTap()
    }

    func testShootTap() {
        let viewController = newViewController()
        viewController.delegate = newDelegateStub()
        viewController.shootButtonViewDidTap()
    }

    func testShootStart() {
        let viewController = newViewController()
        viewController.delegate = newDelegateStub()
        viewController.shootButtonViewDidStartLongPress()
    }

    func testShootEnd() {
        let viewController = newViewController()
        viewController.delegate = newDelegateStub()
        viewController.shootButtonViewDidEndLongPress()
    }
    
    func testDropInteraction() {
        let viewController = newViewController()
        viewController.delegate = newDelegateStub()
        viewController.shootButtonDidReceiveDropInteraction()
    }
}

final class ModeSelectorAndShootDelegateStub: ModeSelectorAndShootControllerDelegate {
    func didDropToDelete(_ mode: CameraMode) {
        XCTAssert(mode == .stopMotion, "Mode did not match for shoot button")
    }
    
    func didOpenMode(_ mode: CameraMode, andClosed oldMode: CameraMode?) {
        XCTAssert(mode == .photo, "The correct mode did not open properly")
    }

    func didTapForMode(_ mode: CameraMode) {
        XCTAssert(mode == .stopMotion, "Mode did not match for shoot button")
    }

    func didStartPressingForMode(_ mode: CameraMode) {
        XCTAssert(mode == .stopMotion, "Mode did not match for shoot button")
    }

    func didEndPressingForMode(_ mode: CameraMode) {
        XCTAssert(mode == .stopMotion, "Mode did not match for shoot button")
    }
    
    func didPanForZoom(_ mode: CameraMode, _ currentPoint: CGPoint, _ gesture: UILongPressGestureRecognizer) {
        XCTAssert(mode == .stopMotion, "Mode did not match for shoot button")
    }
    
    func didDismissWelcomeTooltip() {
        // Works on every mode
    }

    func didTapMediaPickerButton(completion: (() -> ())? = nil) {
        // Works on every mode
    }

    func updateMediaPickerThumbnail(targetSize: CGSize) {
    }
}
