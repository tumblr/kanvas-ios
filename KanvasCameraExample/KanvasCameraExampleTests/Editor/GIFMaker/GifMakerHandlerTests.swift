//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

final class GifMakerHandlerTests: XCTestCase {

    func testGifMakerHandler() {
        let handler = GifMakerHandler(player: MediaPlayer(renderer: nil))
        XCTAssert(type(of: handler) == GifMakerHandler.self)
    }

}
