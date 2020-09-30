//
//  ThumbnailCollectionViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 18/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ThumbnailCollectionViewTests: FBSnapshotTestCase, UICollectionViewDataSource, ThumbnailCollectionViewLayoutDelegate {
    
    private let thumbnailCount: Int = 4
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> ThumbnailCollectionView {
        let view = ThumbnailCollectionView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: ThumbnailCollectionCell.cellHeight)
        view.backgroundColor = .black
        view.collectionView.register(cell: ThumbnailCollectionCell.self)
        view.collectionView.dataSource = self
        view.collectionViewLayout.delegate = self
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnailCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCollectionCell.identifier, for: indexPath)
        if let cell = cell as? ThumbnailCollectionCell {
            let timeInterval = TimeInterval(0)
            cell.bindTo(timeInterval)
        }
        return cell
    }
    
    // MARK: - ThumbnailCollectionViewLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, widthForCellAt indexPath: IndexPath) -> CGFloat {
        return ThumbnailCollectionCell.cellWidth
    }
}
