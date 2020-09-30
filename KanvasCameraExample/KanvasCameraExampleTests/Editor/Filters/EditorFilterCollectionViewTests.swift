//
//  EditorFilterCollectionViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 21/05/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class EditorFilterCollectionViewTests: FBSnapshotTestCase, UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        let collectionView = FilterCollectionView(cellWidth: EditorFilterCollectionCell.width, cellHeight: EditorFilterCollectionCell.minimumHeight)
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: EditorFilterCollectionCell.minimumHeight + 10)
        return collectionView
    }
    
    func testCompareCollectionView() {
        let view = newCollectionView()
        view.collectionView.register(cell: EditorFilterCollectionCell.self)
        view.collectionView.delegate = self
        view.collectionView.dataSource = self
        view.collectionView.reloadData()
        FBSnapshotVerifyView(view)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditorFilterCollectionCell.identifier, for: indexPath)
        if let filterCell = cell as? EditorFilterCollectionCell {
            filterCell.bindTo(filters[indexPath.item])
        }
        return cell
    }
}
