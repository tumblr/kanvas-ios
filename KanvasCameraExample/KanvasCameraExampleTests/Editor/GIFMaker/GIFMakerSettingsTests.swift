//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

final class GifMakerSettingsTests: XCTestCase {

    func testGifMakerSettings() {
        let settings = GIFMakerSettings(rate: 1.0, startIndex: 0, endIndex: 10, playbackMode: .loop)
        XCTAssertEqual(settings.rate, 1.0)
        XCTAssertEqual(settings.startIndex, 0)
        XCTAssertEqual(settings.endIndex, 10)
        XCTAssertEqual(settings.playbackMode, PlaybackOption.loop)
    }

}
