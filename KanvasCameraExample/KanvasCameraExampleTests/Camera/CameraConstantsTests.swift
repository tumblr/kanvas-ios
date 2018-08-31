//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest
import Foundation
@testable import KanvasCamera

final class CameraConstantsTests: XCTestCase {
    
    func testButtonSize() {
        XCTAssert(34 == CameraConstants.ButtonSize, "Button size should match expected value")
    }

    func testButtonMargin() {
        XCTAssert(32 == CameraConstants.ButtonMargin, "Button margin should match expected value")
    }

}
