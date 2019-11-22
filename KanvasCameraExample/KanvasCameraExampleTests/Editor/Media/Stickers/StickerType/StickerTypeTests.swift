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

final class StickerTypeTests: XCTestCase {
    
    func testStickerType() {
        let imageUrl = "https://d1d7t1ygvx8siu.cloudfront.net/SDK-Assets/stamps.tistheseason/pack.jpg"
        let stickerType = StickerType(baseUrl: "https://d1d7t1ygvx8siu.cloudfront.net/SDK-Assets/",
        keyword: "stamps.tistheseason",
        thumbUrl: "pack.jpg",
        count: 28)
        XCTAssertEqual(stickerType.imageUrl, imageUrl, "Image URL does not match")
    }
}
