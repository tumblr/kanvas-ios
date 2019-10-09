//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class HorizontalCollectionLayoutTests: XCTestCase {
    
    func newLayout(itemSize: CGFloat) -> HorizontalCollectionLayout {
        return HorizontalCollectionLayout(cellWidth: itemSize, minimumHeight: itemSize)
    }
    
    func testEstimatedItemSize() {
        let itemSize: CGFloat = 30
        let layout = newLayout(itemSize: itemSize)
        XCTAssertEqual(layout.estimatedItemSize.width, itemSize, "Item width should be 30.")
        XCTAssertEqual(layout.estimatedItemSize.height, itemSize, "Item height should be 30.")
    }
}
