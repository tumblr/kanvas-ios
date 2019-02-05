//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

final class RGBATests: XCTestCase {
    
    func testRGBA() {
        let rgba = UIColor.blue.rgbaComponents
        XCTAssertTrue(rgba.red == 0 && rgba.green == 0 && rgba.blue == 1 && rgba.alpha == 1)
    }
}
