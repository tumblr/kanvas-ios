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

final class PlaybackViewTests: FBSnapshotTestCase, UICollectionViewDataSource {
    
    private let options: [PlaybackOption] = [.loop, .rebound, .reverse]
    private let selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> PlaybackView {
        let view = PlaybackView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: PlaybackView.height)
        let cellWidth = view.frame.width / CGFloat(options.count)
        PlaybackCollectionCell.width = cellWidth
        view.cellWidth = cellWidth
        view.selectionViewWidth = cellWidth
        view.collectionView.register(cell: PlaybackCollectionCell.self)
        view.collectionView.dataSource = self
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaybackCollectionCell.identifier, for: indexPath) as? PlaybackCollectionCell, let option = options.object(at: indexPath.item)
            else { return UICollectionViewCell() }
        
        cell.bindTo(option)
        
        if indexPath == selectedIndexPath {
            cell.setSelected(true, animated: false)
        }
        return cell
    }
}
