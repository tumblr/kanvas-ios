//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest
import FBSnapshotTestCase

final class ActionsViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newView() -> ActionsView {
        let view = ActionsView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }

    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }

    func testHideUndo() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.updateUndo(enabled: false)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testShowUndo() {
        let view = newView()
        view.updateUndo(enabled: false)
        UIView.setAnimationsEnabled(false)
        view.updateUndo(enabled: true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testHideNext() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.updateNext(enabled: false)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testShowNext() {
        let view = newView()
        view.updateNext(enabled: false)
        UIView.setAnimationsEnabled(false)
        view.updateNext(enabled: true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

}
