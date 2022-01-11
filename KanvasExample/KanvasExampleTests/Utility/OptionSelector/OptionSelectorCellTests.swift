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

final class OptionSelectorCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> OptionSelectorCell {
        let frame = CGRect(origin: .zero,
                           size: CGSize(width: 100, height: OptionSelectorView.height))
        return OptionSelectorCell(frame: frame)
    }
    
    func testCell() {
        let cell = newCell()
        cell.bindTo(PlaybackOption.loop)
        FBSnapshotVerifyView(cell, tolerance: 0.05)
    }
    
    func testSelectedCell() {
        let cell = newCell()
        cell.bindTo(PlaybackOption.loop)
        cell.setSelected(true, animated: false)
        FBSnapshotVerifyView(cell, tolerance: 0.05)
    }
}
