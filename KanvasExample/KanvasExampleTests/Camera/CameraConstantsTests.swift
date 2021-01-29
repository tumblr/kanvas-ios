//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import XCTest

final class CameraConstantsTests: XCTestCase {
    
    func testButtonSize() {
        XCTAssert(26.5 == CameraConstants.optionButtonSize, "Button size should match expected value")
    }

    func testOptionHorizontalMargin() {
        XCTAssert(24 == CameraConstants.optionHorizontalMargin, "Option horizontal margin should match expected value")
    }
    
    func testOptionVerticalMargin() {
        XCTAssert(24 == CameraConstants.optionVerticalMargin, "Option vertical margin should match expected value")
    }
    
    func testOptionSpacing() {
        XCTAssert(33 == CameraConstants.optionSpacing, "Option spacing should match expected value")
    }
}
