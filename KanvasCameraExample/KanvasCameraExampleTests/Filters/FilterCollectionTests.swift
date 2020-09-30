//
//  FilterCollectionTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 21/06/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class FilterCollectionTests: FBSnapshotTestCase, UICollectionViewDelegate, UICollectionViewDataSource {
    
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
    
    func newLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = CGSize(width: CameraFilterCollectionCell.width, height: CameraFilterCollectionCell.minimumHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }
    
    func newCollectionView() -> HorizontalCollectionView {
        let frame = CGRect(x: 0, y: 0, width: 320, height: CameraFilterCollectionCell.minimumHeight + 10)
        let layout = newLayout()
        let collectionView = HorizontalCollectionView(frame: frame, collectionViewLayout: layout, ignoreTouches: false)
        return collectionView
    }
    
    func testCompareCollectionView() {
        let collectionView = newCollectionView()
        collectionView.register(cell: CameraFilterCollectionCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        FBSnapshotVerifyView(collectionView)
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
