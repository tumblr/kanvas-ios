//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class MediaClipsCollectionViewTests: FBSnapshotTestCase, UICollectionViewDelegate, UICollectionViewDataSource {

    var clips: [MediaClip] = []

    override func setUp() {
        super.setUp()

        for _ in 0...3 {
            if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
                let clip = MediaClip(representativeFrame: image, overlayText: nil)
                clips.append(clip)
            }
        }

        self.recordMode = false
    }

    func newCollectionView() -> MediaClipsCollectionView {
        let collectionView = MediaClipsCollectionView()
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: 120)
        return collectionView
    }

    func testCompareCollectionView() {
        let view = newCollectionView()
        view.collectionView.register(cell: MediaClipsCollectionCell.self)
        view.collectionView.delegate = self
        view.collectionView.dataSource = self
        view.collectionView.reloadData()
        FBSnapshotVerifyView(view)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaClipsCollectionCell.identifier, for: indexPath)
        if let clipCell = cell as? MediaClipsCollectionCell {
            clipCell.bindTo(clips[indexPath.item])
        }
        return cell
    }
}
