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

final class PlaybackCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> PlaybackCollectionCell {
        let frame = CGRect(origin: .zero,
                           size: CGSize(width: 100, height: PlaybackView.height))
        return PlaybackCollectionCell(frame: frame)
    }
    
    func testCell() {
        let cell = newCell()
        cell.bindTo(.loop)
        FBSnapshotVerifyView(cell)
    }
    
    func testSelectedCell() {
        let cell = newCell()
        cell.bindTo(.loop)
        cell.isSelected = true
        FBSnapshotVerifyView(cell)
    }
}
