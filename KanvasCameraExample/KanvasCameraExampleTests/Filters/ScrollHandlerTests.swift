//
//  ScrollHandlerTests.swift
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

final class ScrollHandlerTests: XCTestCase {
    
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

    
    func testScrollHandler() {
        let collectionView = newCollectionView()
        let scrollHandler = ScrollHandler(collectionView: collectionView, cellWidth: CameraFilterCollectionCell.width, cellHeight: CameraFilterCollectionCell.minimumHeight)
        let delegate = ScrollHandlerDelegateStub()
        scrollHandler.delegate = delegate
        scrollHandler.scrollViewDidScroll(UIScrollView())
        XCTAssertTrue(delegate.indexPathAtSelectionCircleCalled, "indexPathAtSelectionCircleCalled was expected to be true")
    }
}


final class ScrollHandlerDelegateStub: ScrollHandlerDelegate {
    private(set) var indexPathAtSelectionCircleCalled = false
    private(set) var calculateDistanceFromSelectionCircleCalled = false
    private(set) var selectFilterCalled = false
    private(set) var scrollToOptionAtCalled = false
    
    func indexPathAtSelectionCircle() -> IndexPath? {
        indexPathAtSelectionCircleCalled = true
        return IndexPath(item: 0, section: 0)
    }
    
    func calculateDistanceFromSelectionCircle(cell: FilterCollectionCell) -> CGFloat {
        calculateDistanceFromSelectionCircleCalled = true
        return CGFloat(0)
    }
    
    func selectFilter(index: Int, animated: Bool) {
        selectFilterCalled = true
    }
    
    func scrollToOption(at index: Int, animated: Bool) {
        scrollToOptionAtCalled = true
    }
}
