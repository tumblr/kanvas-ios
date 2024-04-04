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
        cell.setStyle(isCenter: false, isFirst: true, isLast: false)
        FBSnapshotArchFriendlyVerifyView(cell)
    }
    
    func testEndingCell() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: true)
        FBSnapshotArchFriendlyVerifyView(cell)
    }
    
    func testCellWhenLeftSideIsActive() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: true, rightLineActive: false)
        FBSnapshotArchFriendlyVerifyView(cell)
    }
    
    func testCellWhenRightSideIsActive() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: false, rightLineActive: true)
        FBSnapshotArchFriendlyVerifyView(cell)
    }
    
    func testInactiveCellOnBothSides() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: false, rightLineActive: false)
        FBSnapshotArchFriendlyVerifyView(cell)
    }
    
    func testActiveCellOnBothSides() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: false, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: true, rightLineActive: true)
        FBSnapshotArchFriendlyVerifyView(cell)
    }
    
    func testCircle() {
        let cell = newCell()
        cell.backgroundColor = .darkGray
        cell.bindTo(0)
        cell.setStyle(isCenter: true, isFirst: false, isLast: false)
        cell.setProgress(leftLineActive: false, rightLineActive: false)
        FBSnapshotArchFriendlyVerifyView(cell, overallTolerance: 0.05)
    }
}
