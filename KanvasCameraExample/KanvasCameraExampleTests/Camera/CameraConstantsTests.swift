//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class CameraConstantsTests: XCTestCase {
    
    func testButtonSize() {
        XCTAssert(24 == CameraConstants.settingsButtonSize, "Button size should match expected value")
    }

    func testButtonMargin() {
        XCTAssert(32 == CameraConstants.buttonMargin, "Button margin should match expected value")
    }

}
