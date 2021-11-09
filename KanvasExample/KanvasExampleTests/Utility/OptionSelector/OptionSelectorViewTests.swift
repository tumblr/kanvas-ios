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

final class OptionSelectorViewTests: FBSnapshotTestCase, UICollectionViewDataSource {
    
    private let options: [OptionSelectorItem] = [PlaybackOption.loop, PlaybackOption.rebound, PlaybackOption.reverse]
    private let selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> OptionSelectorView {
        let view = OptionSelectorView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: OptionSelectorView.height)
        let cellWidth = view.frame.width / CGFloat(options.count)
        OptionSelectorCell.width = cellWidth
        view.cellWidth = cellWidth
        view.selectionViewWidth = cellWidth
        view.collectionView.register(cell: OptionSelectorCell.self)
        view.collectionView.dataSource = self
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionSelectorCell.identifier, for: indexPath) as? OptionSelectorCell, let option = options.object(at: indexPath.item)
            else { return UICollectionViewCell() }
        
        cell.bindTo(option)
        
        if indexPath == selectedIndexPath {
            cell.setSelected(true, animated: false)
        }
        return cell
    }
}
