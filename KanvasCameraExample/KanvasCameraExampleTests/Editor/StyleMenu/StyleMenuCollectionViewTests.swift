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

final class StyleMenuCollectionViewTests: FBSnapshotTestCase, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var editionOptions: [EditionOption] = []
    
    override func setUp() {
        super.setUp()
        
        editionOptions = [
            .filter,
            .media,
        ]
        
        self.recordMode = false
    }
    
    func newCollectionView() -> StyleMenuCollectionView {
        let collectionView = StyleMenuCollectionView()
        collectionView.frame = CGRect(x: 0, y: 0, width: StyleMenuCollectionCell.width, height: StyleMenuCollectionCell.height * 10)
        return collectionView
    }
    
    func testCompareCollectionView() {
        let view = newCollectionView()
        view.collectionView.register(cell: StyleMenuCollectionCell.self)
        view.collectionView.delegate = self
        view.collectionView.dataSource = self
        view.collectionView.reloadData()
        FBSnapshotVerifyView(view)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StyleMenuCollectionCell.identifier, for: indexPath)
        if let editionMenuCell = cell as? StyleMenuCollectionCell {
            editionMenuCell.bindTo(editionOptions[indexPath.item], enabled: false)
        }
        return cell
    }
}
