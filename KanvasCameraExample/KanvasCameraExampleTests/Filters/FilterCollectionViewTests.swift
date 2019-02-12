//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import UIKit
import XCTest

final class FilterCollectionViewTests: FBSnapshotTestCase, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var filters: [Filter] = []
    
    override func setUp() {
        super.setUp()
        
        filters = [Filter(representativeColor: .tumblrBrightRed),
                   Filter(representativeColor: .tumblrBrightPink),
                   Filter(representativeColor: .tumblrBrightOrange),
                   Filter(representativeColor: .tumblrBrightYellow),
                   Filter(representativeColor: .tumblrBrightGreen),
                   Filter(representativeColor: .tumblrBrightBlue),
                   Filter(representativeColor: .tumblrBrightPurple)]
        
        self.recordMode = false
    }
    
    func newCollectionView() -> FilterCollectionView {
        let collectionView = FilterCollectionView()
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: FilterCollectionView.height)
        return collectionView
    }
    
    func testCompareCollectionView() {
        let view = newCollectionView()
        view.collectionView.register(cell: FilterCollectionCell.self)
        view.collectionView.delegate = self
        view.collectionView.dataSource = self
        view.collectionView.reloadData()
        FBSnapshotVerifyView(view)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionCell.identifier, for: indexPath)
        if let filterCell = cell as? FilterCollectionCell {
            filterCell.bindTo(filters[indexPath.item])
        }
        return cell
    }
}
