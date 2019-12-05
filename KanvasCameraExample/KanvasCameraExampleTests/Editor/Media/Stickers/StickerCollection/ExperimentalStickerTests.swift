//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import KanvasCameraExample
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ExperimentalStickerTests: XCTestCase {
    
    func testExperimentalSticker() {
        let imageUrl = "https://d1d7t1ygvx8siu.cloudfront.net/SDK-Assets/stamps.tistheseason/01.jpg"
        let sticker = ExperimentalSticker(baseUrl: "https://d1d7t1ygvx8siu.cloudfront.net/SDK-Assets/",
                              keyword: "stamps.tistheseason",
                              number: 1,
                              imageExtension: "jpg")
        XCTAssertEqual(sticker.getImageUrl(), imageUrl, "Image URL does not match")
    }
}
