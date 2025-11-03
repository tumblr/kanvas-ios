//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import XCTest

final class KanvasDesignTests: XCTestCase {

    func testOriginal() {
        XCTAssertFalse(KanvasDesign.original.isBottomPicker, "The result should be false.")
    }
    
    func testBottomPicker() {
        XCTAssertTrue(KanvasDesign.bottomPicker.isBottomPicker, "The result should be true.")
    }

}
