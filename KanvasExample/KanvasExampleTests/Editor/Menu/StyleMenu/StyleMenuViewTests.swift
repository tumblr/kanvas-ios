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

final class StyleMenuViewTests: FBSnapshotTestCase, StyleMenuViewDelegate {
    
    var editionOptions: [EditionOption] = []
    
    override func setUp() {
        super.setUp()
        
        editionOptions = [
            .filter,
            .media,
            .text,
            .drawing,
        ]
        
        self.recordMode = false
    }
    
    func newCollectionView() -> StyleMenuView {
        let collectionView = StyleMenuView(delegate: self)
        collectionView.frame = CGRect(x: 0, y: 0, width: 375, height: StyleMenuCell.height * 10)
        return collectionView
    }
    
    func testMenuCollapsed() {
        let view = newCollectionView()
        view.load()
        FBSnapshotVerifyView(view)
    }
    
    func testMenuExpanded() {
        let view = newCollectionView()
        view.load()
        view.setNeedsLayout()
        view.expandCollection()
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }
    
    // MARK: - StyleMenuViewDelegate
    
    func numberOfItems() -> Int {
        return editionOptions.count
    }
    
    func bindItem(at index: Int, cell: StyleMenuCell) {
        guard let option = editionOptions.object(at: index) else { return }
        cell.bindTo(option, enabled: false)
    }
    
    func didSelect(cell: StyleMenuCell) {
        // No-op
    }
}
