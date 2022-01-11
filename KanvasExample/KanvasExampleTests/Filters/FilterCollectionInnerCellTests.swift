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

private struct CellCustomDimensions: FilterCollectionCellDimensions {
    var circleDiameter: CGFloat = 72
    var circleMaxDiameter: CGFloat = 96.1
    var padding: CGFloat = 0
    var minimumHeight: CGFloat { return circleMaxDiameter }
    var width: CGFloat { return circleMaxDiameter }
}

final class FilterCollectionInnerCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> FilterCollectionInnerCell {
        let dimensions = CellCustomDimensions()
        let cell = FilterCollectionInnerCell(dimensions: dimensions)
        
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100))
        cell.frame = frame
        return cell
    }
    
    func testFilterCell() {
        let cell = newCell()
        let filterItem = FilterItem(type: .lightLeaks)
        cell.bindTo(filterItem)
        FBSnapshotVerifyView(cell, tolerance: 0.05)
    }
}
