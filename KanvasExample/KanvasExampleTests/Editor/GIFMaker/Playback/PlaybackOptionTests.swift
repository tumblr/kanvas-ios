//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class PlaybackOptionTests: XCTestCase {
    
    func testOptionType() {
        let option = PlaybackOption.loop
        XCTAssertEqual(option, .loop, "Playback option does not match")
    }
}
