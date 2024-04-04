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

final class ModeButtonViewTests: FBSnapshotTestCase {
        
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newModeButton() -> ModeButtonView {
        let modeButton = ModeButtonView()
        return modeButton
    }
    
    func testPhotoMode() {
        let modeButton = newModeButton()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        modeButton.setTitle(KanvasStrings.name(for: .photo))
        FBSnapshotArchFriendlyVerifyView(modeButton, overallTolerance: 0.05)
        UIView.setAnimationsEnabled(true)
    }
    
    func testGifMode() {
        let modeButton = newModeButton()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        modeButton.setTitle(KanvasStrings.name(for: .loop))
        FBSnapshotArchFriendlyVerifyView(modeButton, overallTolerance: 0.05)
        UIView.setAnimationsEnabled(true)
    }

    func testStopMotionMode() {
        let modeButton = newModeButton()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        modeButton.setTitle(KanvasStrings.name(for: .stopMotion))
        FBSnapshotArchFriendlyVerifyView(modeButton, overallTolerance: 0.05)
        UIView.setAnimationsEnabled(true)
    }
}
