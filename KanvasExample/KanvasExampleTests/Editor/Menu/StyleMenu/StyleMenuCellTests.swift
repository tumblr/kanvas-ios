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

final class StyleMenuCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> StyleMenuCell {
        let cell = StyleMenuCell()
        cell.frame = CGRect(x: 0, y: 0, width: 122, height: StyleMenuCell.height)
        return cell
    }
    
    func testCell() {
        let cell = newCell()
        let editionOption = EditionOption.media
        cell.bindTo(editionOption, enabled: false)
        cell.layoutIfNeeded()
        FBSnapshotVerifyView(cell, tolerance: 0.05)
    }
}
