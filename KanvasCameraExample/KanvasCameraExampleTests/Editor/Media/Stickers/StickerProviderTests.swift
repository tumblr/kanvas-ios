//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

class StickerProviderTests: XCTestCase {

    func testGetDataFromStickersFile() {
        let stickerProvider = StickerProvider()
        let data = stickerProvider.getData()
        XCTAssertFalse(data.isEmpty)
    }
}
