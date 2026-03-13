//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import XCTest

final class IndexPathOrderTests: XCTestCase {
    
    // MARK: - #.move(from:to:)
    func testNext() {
        let indexPath = IndexPath(item: 0, section: 0)
        let nextIndexPath = indexPath.next()
        XCTAssertEqual(nextIndexPath.item, 1, "Expected item to be 1.")
    }
    
    func testPrevious() {
        let indexPath = IndexPath(item: 2, section: 0)
        let previousIndexPath = indexPath.previous()
        XCTAssertEqual(previousIndexPath.item, 1, "Expected item to be 1.")
    }
    
    func testSectionWithNext() {
        let indexPath = IndexPath(item: 0, section: 0)
        let nextIndexPath = indexPath.next()
        XCTAssertEqual(nextIndexPath.section, 0, "Expected section to be 0.")
    }
    
    func testSectionWithPrevious() {
        let indexPath = IndexPath(item: 0, section: 0)
        let previousIndexPath = indexPath.previous()
        XCTAssertEqual(previousIndexPath.section, 0, "Expected section to be 0.")
    }
}
