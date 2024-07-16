//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
import UIKit
import XCTest

final class ShootButtonViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newShootButtonView() -> ShootButtonView {
        let shootButton = ShootButtonView(baseColor: .white)
        return shootButton
    }
    
    func testPhotoMode() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.configureFor(trigger: .tap, image: KanvasImages.photoModeImage, timeLimit: KanvasTimes.stopMotionFrameTimeInterval)
        FBSnapshotArchFriendlyVerifyView(shootButton)
        UIView.setAnimationsEnabled(true)
    }

    func testGifMode() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.configureFor(trigger: .tap, image: KanvasImages.loopModeImage, timeLimit: KanvasTimes.gifTapRecordingTime)
        FBSnapshotArchFriendlyVerifyView(shootButton)
        UIView.setAnimationsEnabled(true)
    }

    func testStopMotionMode() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.configureFor(trigger: .tapOrHold(animateCircle: true), image: KanvasImages.stopMotionModeImage, timeLimit: KanvasTimes.videoRecordingTime)
        FBSnapshotArchFriendlyVerifyView(shootButton)
        UIView.setAnimationsEnabled(true)
    }
    
    func testShowOpenTrash() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.openTrash()
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(shootButton)
    }
    
    func testShowClosedTrash() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.closeTrash()
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(shootButton)
    }
    
    func testOpenAndHideTrash() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.openTrash()
        shootButton.hideTrash()
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(shootButton)
    }
    
    func testCloseAndHideTrash() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.openTrash()
        shootButton.hideTrash()
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(shootButton)
    }
}
