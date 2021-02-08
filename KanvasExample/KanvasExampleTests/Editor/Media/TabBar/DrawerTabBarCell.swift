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

final class DrawerTabBarCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> DrawerTabBarCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: DrawerTabBarCell.width, height: DrawerTabBarCell.height))
        return DrawerTabBarCell(frame: frame)
    }
    
    func testTabBarCell() {
        let cell = newCell()
        let tabBarOption = DrawerTabBarOption.stickers
        cell.bindTo(tabBarOption)
        FBSnapshotVerifyView(cell)
    }
}
