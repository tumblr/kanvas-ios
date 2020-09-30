//
//  ThumbnailCollectionCellTests.swift
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

final class ThumbnailCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> ThumbnailCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: ThumbnailCollectionCell.cellWidth,
                                        height: ThumbnailCollectionCell.cellHeight))
        return ThumbnailCollectionCell(frame: frame)
    }
    
    func testThumbnailCollectionCell() {
        let cell = newCell()
        cell.backgroundColor = .black
        cell.bindTo(0)
        FBSnapshotVerifyView(cell)
    }
}
