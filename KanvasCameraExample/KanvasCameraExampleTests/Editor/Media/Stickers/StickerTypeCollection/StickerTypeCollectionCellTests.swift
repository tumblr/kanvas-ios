//
//  StickerTypeCollectionCellTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 18/11/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class StickerTypeCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> StickerTypeCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: StickerTypeCollectionCell.totalWidth, height: StickerTypeCollectionCell.totalHeight))
        return StickerTypeCollectionCell(frame: frame)
    }
    
    func testStickerTypeCollectionCell() {
        let cell = newCell()
        let stickerType = StickerType(id: "id", imageUrl: "imageUrl", stickers: [])
        
        cell.bindTo(stickerType)
        FBSnapshotVerifyView(cell)
    }
}
