//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class TrashViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newTrashView() -> TrashView {
        let trashView = TrashView()
        trashView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        return trashView
    }

    func testShowOpenTrash() {
        let trashView = newTrashView()
        UIView.setAnimationsEnabled(false)
        trashView.open()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(trashView)
    }
    
    func testShowClosedTrash() {
        let trashView = newTrashView()
        UIView.setAnimationsEnabled(false)
        trashView.close()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(trashView)
    }
    
    func testOpenAndHideTrash() {
        let trashView = newTrashView()
        UIView.setAnimationsEnabled(false)
        trashView.open()
        trashView.hide()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(trashView)
    }
    
    func testCloseAndHideTrash() {
        let trashView = newTrashView()
        UIView.setAnimationsEnabled(false)
        trashView.close()
        trashView.hide()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(trashView)
    }

}
