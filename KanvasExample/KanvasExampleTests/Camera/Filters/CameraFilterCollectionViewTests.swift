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

final class CameraFilterCollectionViewTests: FBSnapshotTestCase, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var filters: [FilterItem] = []
    
    override func setUp() {
        super.setUp()
        
        filters = [
            FilterItem(type: .passthrough),
            FilterItem(type: .wavePool),
            FilterItem(type: .plasma),
            FilterItem(type: .emInterference),
            FilterItem(type: .rgb),
            FilterItem(type: .lego),
            FilterItem(type: .chroma),
            FilterItem(type: .rave),
            FilterItem(type: .mirrorTwo),
            FilterItem(type: .mirrorFour),
            FilterItem(type: .lightLeaks),
            FilterItem(type: .film),
            FilterItem(type: .grayscale),
            FilterItem(type: .manga),
            FilterItem(type: .toon),
        ]
        
        self.recordMode = false
    }
    
    func newCollectionView() -> FilterCollectionView {
        let collectionView = FilterCollectionView(cellWidth: CameraFilterCollectionCell.width, cellHeight: CameraFilterCollectionCell.minimumHeight)
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: CameraFilterCollectionCell.minimumHeight + 10)
        return collectionView
    }
    
    func testCompareCollectionView() {
        let view = newCollectionView()
        view.collectionView.register(cell: CameraFilterCollectionCell.self)
        view.collectionView.delegate = self
        view.collectionView.dataSource = self
        view.collectionView.reloadData()
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraFilterCollectionCell.identifier, for: indexPath)
        if let filterCell = cell as? CameraFilterCollectionCell {
            filterCell.bindTo(filters[indexPath.item])
        }
        return cell
    }
}
