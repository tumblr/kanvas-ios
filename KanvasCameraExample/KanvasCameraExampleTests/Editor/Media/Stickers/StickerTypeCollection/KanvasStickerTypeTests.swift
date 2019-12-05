//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest


final class KanvasStickerTypeTests: XCTestCase {
    
    func testKanvasStickerType() {
        let imageUrl = "https://d1d7t1ygvx8siu.cloudfront.net/SDK-Assets/stamps.tistheseason/pack.jpg"
        
        let original = Image(url: URL(string: imageUrl), width: 200, height: 200)
        let alternate = Image(url: URL(string: imageUrl), width: 100, height: 100)
        let images = Image.Sizes(original: original, alternate: alternate)
        let sticker = KanvasStickerType(id: 0, description: "description", image: images, sponsored: false, title: "title", stickers: [])
        
        XCTAssertEqual(stickerType.getImageUrl(), imageUrl, "Image URL does not match")
    }
}
