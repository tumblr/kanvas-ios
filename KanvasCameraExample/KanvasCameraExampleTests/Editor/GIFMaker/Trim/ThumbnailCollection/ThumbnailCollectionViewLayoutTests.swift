//
//  ThumbnailCollectionViewLayoutTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 23/06/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class ThumbnailCollectionViewLayoutTests: XCTestCase, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let itemCount: Int = 10
    
    func testDelegate() {
        let layout = ThumbnailCollectionViewLayout()
        let delegate = ThumbnailCollectionViewLayoutDelegateStub()
        layout.delegate = delegate
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(cell: ThumbnailCollectionCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layoutIfNeeded()
        collectionView.setNeedsDisplay()
        XCTAssert(delegate.called, "Delegate method was not called.")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCollectionCell.identifier, for: indexPath)
    }
}

private class ThumbnailCollectionViewLayoutDelegateStub: ThumbnailCollectionViewLayoutDelegate {
    
    private static let cellWidth: CGFloat = 30
    
    private(set) var called = false
    
    func collectionView(_ collectionView: UICollectionView, widthForCellAt indexPath: IndexPath) -> CGFloat {
        called = true
        return ThumbnailCollectionViewLayoutDelegateStub.cellWidth
    }
}
