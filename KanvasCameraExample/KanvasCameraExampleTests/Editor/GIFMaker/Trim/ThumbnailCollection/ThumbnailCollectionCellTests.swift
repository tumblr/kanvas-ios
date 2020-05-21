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

final class ThumbnailCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> ThumbnailCollectionCell {
        let size = TrimView.height
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: size, height: size))
        return ThumbnailCollectionCell(frame: frame)
    }
    
    func testThumbnailCollectionCell() {
        let cell = newCell()
        FBSnapshotVerifyView(cell)
    }
}
