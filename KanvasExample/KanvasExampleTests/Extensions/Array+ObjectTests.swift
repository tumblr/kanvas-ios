//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import XCTest

final class ArrayObjectTests: XCTestCase {
    
    func testIndexWithinBounds() {
        let array = ["a", "b", "c", "d"]
        let element = array.object(at: 0)
        XCTAssertNotNil(element, "Expected element not to be nil.")
    }
    
    func testIndexAboveUpperBound() {
        let array = ["a", "b", "c", "d"]
        let element = array.object(at: 10)
        XCTAssertNil(element, "Expected element to be nil.")
    }
    
    func testIndexBelowLowerBound() {
        let array = ["a", "b", "c", "d"]
        let element = array.object(at: -5)
        XCTAssertNil(element, "Expected element to be nil.")
    }
}
