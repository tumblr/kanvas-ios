//
//  StaggeredGridLayoutTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 22/11/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class StaggeredGridLayoutTests: XCTestCase {
    
    func newLayout(numberOfColumns: Int, cellPadding: CGFloat) -> StaggeredGridLayout {
        return StaggeredGridLayout(numberOfColumns: numberOfColumns, cellPadding: cellPadding)
    }
    
    func testEstimatedItemSize() {
        let layout = newLayout(numberOfColumns: 4, cellPadding: 10)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 200, height: 100), collectionViewLayout: layout)
        collectionView.setNeedsDisplay()
        let expectedItemWidth: CGFloat = 30.0
        XCTAssertEqual(layout.itemWidth, expectedItemWidth, "Item width does not match.")
    }
}
