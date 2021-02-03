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

final class StickerTypeCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> StickerTypeCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: StickerTypeCollectionCell.totalWidth, height: StickerTypeCollectionCell.totalHeight))
        return StickerTypeCollectionCell(frame: frame)
    }
    
    func testStickerTypeCollectionCell() {
        let cell = newCell()
        let stickerType = StickerType(id: "id", imageUrl: "imageUrl", stickers: [])
        
        cell.bindTo(stickerType)
        FBSnapshotVerifyView(cell)
    }
}
