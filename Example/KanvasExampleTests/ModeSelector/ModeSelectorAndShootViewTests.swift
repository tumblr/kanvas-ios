//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
import Foundation
import UIKit
import XCTest

final class ModeSelectorAndShootViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> ModeSelectorAndShootView {
        let view = ModeSelectorAndShootView(settings: CameraSettings())
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }

    func testPhotoMode() {
        let view = newView()
        view.setUpMode(.photo)
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }

    func testGifMode() {
        let view = newView()
        view.setUpMode(.loop)
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }

    func testStopMotionMode() {
        let view = newView()
        view.setUpMode(.stopMotion)
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }

    func testShowModeButton() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.showModeButton(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(view)
    }

    func testHideModeButton() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.showModeButton(false)
        UIImageView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(view)
    }

}
