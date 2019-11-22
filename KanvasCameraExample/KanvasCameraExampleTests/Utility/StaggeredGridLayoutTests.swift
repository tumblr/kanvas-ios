//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class StaggeredGridLayoutTests: XCTestCase {
    
    func newLayout(numberOfColumns: Int, cellPadding: CGFloat) -> StaggeredGridLayout {
        return StaggeredGridLayout(numberOfColumns: numberOfColumns, cellPadding: cellPadding)
    }
    
    func testEstimatedItemSize() {
        let layout = newLayout(numberOfColumns: 4, cellPadding: 10)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 100), collectionViewLayout: layout)        
        let expectedItemWidth: CGFloat = 30.0
        XCTAssertEqual(layout.itemWidth, expectedItemWidth, "Item width does not match.")
    }
}
