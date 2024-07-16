//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
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
