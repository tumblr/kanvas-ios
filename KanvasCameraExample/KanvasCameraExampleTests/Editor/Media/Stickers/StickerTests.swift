//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class StickerTests: XCTestCase {
    
    func testSticker() {
        let imageUrl = "example"
        let sticker = Sticker(image: imageUrl)
        XCTAssertEqual(sticker.image, imageUrl, "Image URL does not match")
    }
}
