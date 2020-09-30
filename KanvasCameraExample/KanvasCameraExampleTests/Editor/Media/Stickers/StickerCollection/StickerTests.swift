//
//  StickerTests.swift
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

final class StickerTests: XCTestCase {
    
    func testStickers() {
        let id = "id"
        let url = "imageUrl"
        let sticker = Sticker(id: id, imageUrl: url)
        XCTAssertEqual(sticker.imageUrl, url, "URL does not match")
    }
}
