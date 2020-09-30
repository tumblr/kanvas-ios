//
//  StickerCollectionCellTests.swift
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

final class StickerCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> StickerCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: 100, height: 100))
        return StickerCollectionCell(frame: frame)
    }
    
    func testStickerCollectionCell() {
        let cell = newCell()
        let stickerType = StickerType(id: "id", imageUrl: "imageUrl", stickers: [])
        let sticker = Sticker(id: "id", imageUrl: "imageUrl")
        
        cell.bindTo(sticker, type: stickerType, index: 0)
        FBSnapshotVerifyView(cell)
    }
}
