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

final class CameraFilterCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> CameraFilterCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: CameraFilterCollectionCell.width - 20, height: CameraFilterCollectionCell.minimumHeight))
        return CameraFilterCollectionCell(frame: frame)
    }
    
    func testFilterCell() {
        let cell = newCell()
        let filterItem = FilterItem(type: .lightLeaks)
        cell.bindTo(filterItem)
        FBSnapshotVerifyView(cell, tolerance: 0.05)
    }
}
