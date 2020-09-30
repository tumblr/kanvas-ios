//
//  EditionMenuCollectionViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 15/05/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class EditionMenuCollectionViewTests: FBSnapshotTestCase, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var editionOptions: [EditionOption] = []
    
    override func setUp() {
        super.setUp()
        
        editionOptions = [
            .filter,
            .media,
        ]
        
        self.recordMode = false
    }
    
    func newCollectionView() -> EditionMenuCollectionView {
        let collectionView = EditionMenuCollectionView()
        collectionView.frame = CGRect(x: 0, y: 0, width: 320, height: EditionMenuCollectionView.height)
        collectionView.updateFadeOutEffect()
        return collectionView
    }
    
    func testCompareCollectionView() {
        let view = newCollectionView()
        view.collectionView.register(cell: EditionMenuCollectionCell.self)
        view.collectionView.delegate = self
        view.collectionView.dataSource = self
        view.collectionView.reloadData()
        FBSnapshotVerifyView(view)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditionMenuCollectionCell.identifier, for: indexPath)
        if let editionMenuCell = cell as? EditionMenuCollectionCell {
            editionMenuCell.bindTo(editionOptions[indexPath.item], enabled: false)
        }
        return cell
    }
}
