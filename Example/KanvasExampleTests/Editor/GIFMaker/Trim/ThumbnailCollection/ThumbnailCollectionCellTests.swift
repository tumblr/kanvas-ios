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

final class ThumbnailCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> ThumbnailCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: ThumbnailCollectionCell.cellWidth,
                                        height: ThumbnailCollectionCell.cellHeight))
        return ThumbnailCollectionCell(frame: frame)
    }
    
    func testThumbnailCollectionCell() {
        let cell = newCell()
        cell.backgroundColor = .black
        cell.bindTo(0)
        FBSnapshotArchFriendlyVerifyView(cell)
    }
}
