//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class DiscreteSliderCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newCell() -> DiscreteSliderCollectionCell {
        let size = 36
        let frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        return DiscreteSliderCollectionCell(frame: frame)
    }
        
    func testBeginningCell() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setPosition(isStart: true, isEnd: false)
        FBSnapshotVerifyView(cell)
    }
    
    func testEndingCell() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setPosition(isStart: false, isEnd: true)
        FBSnapshotVerifyView(cell)
    }
    
    func testCellWhenLeftSideIsActive() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setPosition(isStart: false, isEnd: false)
        cell.setProgress(leftActive: true, rightActive: false)
        FBSnapshotVerifyView(cell)
    }
    
    func testCellWhenRightSideIsActive() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setPosition(isStart: false, isEnd: false)
        cell.setProgress(leftActive: false, rightActive: true)
        FBSnapshotVerifyView(cell)
    }
    
    func testInactiveCellOnBothSides() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setPosition(isStart: false, isEnd: false)
        cell.setProgress(leftActive: false, rightActive: false)
        FBSnapshotVerifyView(cell)
    }
    
    func testActiveCellOnBothSides() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setPosition(isStart: false, isEnd: false)
        cell.setProgress(leftActive: true, rightActive: true)
        FBSnapshotVerifyView(cell)
    }
}
