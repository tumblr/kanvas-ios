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

final class LoadingIndicatorViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newView() -> LoadingIndicatorView {
        let view = LoadingIndicatorView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }

    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }

    func testStartLoading() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.startLoading()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testStopLoading() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.startLoading()
        view.stopLoading()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testStartAfterStopLoading() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.startLoading()
        view.stopLoading()
        view.startLoading()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

}
