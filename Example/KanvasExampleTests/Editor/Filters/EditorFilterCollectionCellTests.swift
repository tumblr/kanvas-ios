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

final class EditorFilterCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> EditorFilterCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: EditorFilterCollectionCell.width - 20, height: EditorFilterCollectionCell.minimumHeight))
        return EditorFilterCollectionCell(frame: frame)
    }
    
    func testFilterCell() {
        let cell = newCell()
        let filterItem = FilterItem(type: .lightLeaks)
        cell.bindTo(filterItem)
        FBSnapshotArchFriendlyVerifyView(cell, overallTolerance: 0.05)
    }
}
