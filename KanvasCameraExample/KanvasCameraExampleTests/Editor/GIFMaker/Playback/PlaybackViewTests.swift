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
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> PlaybackView {
        let view = PlaybackView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: PlaybackView.height)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaybackCollectionCell.identifier, for: indexPath)
        if let cell = cell as? PlaybackCollectionCell, let option = options.object(at: indexPath.item) {
            cell.bindTo(option)
        }
        return cell
    }
}
