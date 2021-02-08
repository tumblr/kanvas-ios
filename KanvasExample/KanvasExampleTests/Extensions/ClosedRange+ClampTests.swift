//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import XCTest

final class ClosedRangeTests: XCTestCase {
    
    func testClampWithValueBetweenRange() {
        let range = (1 ... 10)
        let middleValue = 5
        let result = range.clamp(middleValue)
        XCTAssertEqual(result, middleValue, "Expected to return 5.")
    }
    
    func testClampWithValueBelowRange() {
        let range = (10 ... 20)
        let result = range.clamp(2)
        XCTAssertEqual(result, range.lowerBound, "Expected to return lower bound of the range (10).")
    }
    
    func testClampWithValueAboveRange() {
        let range = (10 ... 20)
        let result = range.clamp(30)
        XCTAssertEqual(result, range.upperBound, "Expected to return upper bound of the range (20).")
    }
}
