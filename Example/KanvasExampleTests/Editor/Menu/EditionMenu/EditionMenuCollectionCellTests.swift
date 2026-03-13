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

final class EditionMenuCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> EditionMenuCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: EditionMenuCollectionCell.width - 20, height: EditionMenuCollectionCell.height))
        return EditionMenuCollectionCell(frame: frame)
    }
    
    func testFilterCell() {
        let cell = newCell()
        let editionOption = EditionOption.media
        cell.bindTo(editionOption, enabled: false)
        FBSnapshotArchFriendlyVerifyView(cell)
    }
}
