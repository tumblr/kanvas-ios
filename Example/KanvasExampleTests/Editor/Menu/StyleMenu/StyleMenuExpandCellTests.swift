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

final class StyleMenuExpandCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func testOpenCell() {
        let cell = StyleMenuExpandCell()
        cell.frame = CGRect(x: 0, y: 0, width: 120, height: StyleMenuExpandCell.height)
        cell.rotateUp()
        cell.layoutIfNeeded()
        FBSnapshotArchFriendlyVerifyView(cell)
    }
    
    func testClosedCell() {
        let cell = StyleMenuExpandCell()
        cell.frame = CGRect(x: 0, y: 0, width: 115, height: StyleMenuExpandCell.height)
        cell.rotateDown()
        cell.layoutIfNeeded()
        FBSnapshotArchFriendlyVerifyView(cell)
    }
}
