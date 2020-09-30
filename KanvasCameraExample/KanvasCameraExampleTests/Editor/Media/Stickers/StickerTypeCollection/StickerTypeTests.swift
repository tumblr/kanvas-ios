//
//  StickerTypeTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 23/12/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class StickerTypeTests: XCTestCase {
    
    func testStickerTypes() {
        let id = "id"
        let url = "imageUrl"
        let stickers: [Sticker] = []
        let stickerType = StickerType(id: id, imageUrl: url, stickers: stickers)
        XCTAssertEqual(stickerType.imageUrl, url, "URL does not match")
    }
}
