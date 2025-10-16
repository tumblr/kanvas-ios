//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import XCTest

final class KanvasStringsTests: XCTestCase {

    func testPhotoName() {
        XCTAssert(KanvasStrings.name(for: .photo) == "Photo", "String does not match for photo")
    }

    func testGifName() {
        XCTAssert(KanvasStrings.name(for: .loop) == "Loop", "String does not match for gif")
    }

    func testStopMotionName() {
        XCTAssert(KanvasStrings.name(for: .stopMotion) == "Capture", "String does not match for stop motion")
    }

}
