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

final class StyleMenuCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> StyleMenuCollectionCell {
        let size = CGSize(width: StyleMenuCollectionCell.width, height: StyleMenuCollectionCell.height)
        let frame = CGRect(origin: CGPoint.zero, size: size)
        return StyleMenuCollectionCell(frame: frame)
    }
    
    func testCell() {
        let cell = newCell()
        let editionOption = EditionOption.media
        cell.bindTo(editionOption, enabled: false)
        FBSnapshotVerifyView(cell)
    }
}
