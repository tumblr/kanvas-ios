//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

class KanvasStickerProviderTests: XCTestCase {
    
    func testGetStickersFromStickersFile() {
        let stickerProvider = KanvasStickerProvider()
        let type = StickerType(baseUrl: "", keyword: "", thumbUrl: "", count: 10)
        let stickers = stickerProvider.getStickers(for: type)
        XCTAssertTrue(stickers.isEmpty)
    }
    
    func testGetStickerTypesFromStickersFile() {
        let stickerProvider = KanvasStickerProvider()
        let types = stickerProvider.getStickerTypes()
        XCTAssertTrue(types.isEmpty)
    }
}
