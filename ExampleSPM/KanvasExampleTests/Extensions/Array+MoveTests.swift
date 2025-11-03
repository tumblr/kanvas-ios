//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import XCTest

final class ArrayMoveTests: XCTestCase {

    // MARK: - #.move(from:to:)
    func testMoveAltersElementToNewIndex() {
        var array = ["a", "b", "c"]
        array.move(from: 1, to: 2)
        XCTAssertEqual(array.firstIndex(of: "b"), 2, "Expected index to be 2 after movement.")
    }

    func testMoveDoesntAlterQuantity() {
        var array = ["a", "b", "c"]
        array.move(from: 1, to: 2)
        XCTAssertEqual(array.count, 3, "Expected array's count to be unaltered.")
    }

    func testMoveDoesntAlterOrderOfOthers() {
        var array = [1, 2, 3, 4]
        array.move(from: 1, to: 3)
        XCTAssertEqual(array[0], 1, "Expected move to not alter other elements.")
        XCTAssertEqual(array[1], 3, "Expected move to not alter other elements.")
        XCTAssertEqual(array[2], 4, "Expected move to not alter other elements.")
    }

}
