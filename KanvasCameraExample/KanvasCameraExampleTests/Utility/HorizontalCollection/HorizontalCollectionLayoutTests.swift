//
//  HorizontalCollectionLayoutTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 12/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class HorizontalCollectionLayoutTests: XCTestCase {
    
    func newLayout(itemSize: CGFloat) -> HorizontalCollectionLayout {
        return HorizontalCollectionLayout(cellWidth: itemSize, minimumHeight: itemSize)
    }
    
    func testEstimatedItemSize() {
        let itemSize: CGFloat = 30
        let layout = newLayout(itemSize: itemSize)
        XCTAssertEqual(layout.estimatedItemSize.width, itemSize, "Item width should be 30.")
        XCTAssertEqual(layout.estimatedItemSize.height, itemSize, "Item height should be 30.")
    }
}
