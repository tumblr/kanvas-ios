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

final class ColorCollectionViewTests: FBSnapshotTestCase, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var colors: [UIColor] = []
    
    override func setUp() {
        super.setUp()
        
        colors = [
            .tumblrBrightBlue,
            .tumblrBrightRed,
            .tumblrBrightOrange
        ]
        
        self.recordMode = false
    }
    
    func newCollectionView() -> ColorCollectionView {
        let collectionView = ColorCollectionView()
        collectionView.frame = CGRect(x: 0, y: 0,
                                      width: ColorCollectionCell.width * CGFloat(colors.count),
                                      height: CircularImageView.size)
        collectionView.updateFadeOutEffect()
        return collectionView
    }
    
    func testCompareCollectionView() {
        let view = newCollectionView()
        view.collectionView.register(cell: ColorCollectionCell.self)
        view.collectionView.delegate = self
        view.collectionView.dataSource = self
        view.collectionView.reloadData()
        FBSnapshotArchFriendlyVerifyView(view)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionCell.identifier, for: indexPath)
        if let colorCell = cell as? ColorCollectionCell {
            colorCell.bindTo(colors[indexPath.item])
        }
        return cell
    }
}
