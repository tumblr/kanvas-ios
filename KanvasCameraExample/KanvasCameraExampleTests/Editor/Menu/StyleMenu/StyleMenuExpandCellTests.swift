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

final class StyleMenuExpandCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func testOpenCell() {
        let cell = StyleMenuExpandCell()
        cell.frame = CGRect(x: 0, y: 0, width: 120, height: StyleMenuExpandCell.height)
        cell.open()
        cell.layoutIfNeeded()
        FBSnapshotVerifyView(cell)
    }
    
    func testClosedCell() {
        let cell = StyleMenuExpandCell()
        cell.frame = CGRect(x: 0, y: 0, width: 115, height: StyleMenuExpandCell.height)
        cell.close()
        cell.layoutIfNeeded()
        FBSnapshotVerifyView(cell)
    }
}
