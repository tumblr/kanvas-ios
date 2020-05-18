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
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: TrimView.height, height: TrimView.height))
        return ThumbnailCollectionCell(frame: frame)
    }
    
    func testThumbnailCollectionCell() {
        guard let exampleImage = KanvasCameraImages.gradientImage else {
            XCTFail("Example image not found")
            return
        }
        let cell = newCell()
        cell.bindTo(exampleImage)
        FBSnapshotVerifyView(cell)
    }
}
