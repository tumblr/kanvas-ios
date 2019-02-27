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
        XCTAssert(23 == CameraConstants.optionButtonSize, "Button size should match expected value")
    }

    func testOptionHorizontalMargin() {
        XCTAssert(30 == CameraConstants.optionHorizontalMargin, "Option horizontal margin should match expected value")
    }
    
    func testOptionVerticalMargin() {
        XCTAssert(26 == CameraConstants.optionVerticalMargin, "Option vertical margin should match expected value")
    }
    
    func testCloseButtonVerticalMargin() {
        XCTAssert(27 == CameraConstants.closeButtonVerticalMargin, "Close button vertical margin should match expected value")
    }
}
