//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import AVFoundation
import UIKit
import XCTest
import FBSnapshotTestCase

final class CameraViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newView() -> CameraView {
        let view = CameraView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }

    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }

    func testUpdateUIForRecording() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.updateUI(forRecording: true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testUpdateUIForNotRecording() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.updateUI(forRecording: true)
        view.updateUI(forRecording: false)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

}
