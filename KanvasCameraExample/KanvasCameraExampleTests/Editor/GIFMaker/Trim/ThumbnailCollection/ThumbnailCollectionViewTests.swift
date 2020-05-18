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

final class ThumbnailCollectionViewTests: FBSnapshotTestCase, UICollectionViewDataSource {
    
    private var thumbnails: [UIImage] {
        guard let sampleImage = KanvasCameraImages.gradientImage else { return [] }
        return [sampleImage, sampleImage, sampleImage]
    }
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> ThumbnailCollectionView {
        let view = ThumbnailCollectionView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: TrimView.height)
        view.collectionView.register(cell: ThumbnailCollectionCell.self)
        view.collectionView.dataSource = self
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCollectionCell.identifier, for: indexPath)
        if let cell = cell as? ThumbnailCollectionCell, let stickerType = thumbnails.object(at: indexPath.item) {
            cell.bindTo(stickerType)
        }
        return cell
    }
}
