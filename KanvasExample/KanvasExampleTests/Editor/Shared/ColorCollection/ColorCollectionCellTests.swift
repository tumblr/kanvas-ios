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

final class ColorCollectionCellTests: FBSnapshotTestCase {
    
    private let size = 40
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> ColorCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: size, height: size))
        return ColorCollectionCell(frame: frame)
    }
    
    func testColorCell() {
        let cell = newCell()
        let color = UIColor.tumblrBrightBlue
        cell.bindTo(color)
        FBSnapshotVerifyView(cell)
    }
}
