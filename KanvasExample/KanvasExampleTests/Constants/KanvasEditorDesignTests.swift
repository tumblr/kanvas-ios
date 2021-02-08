//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import XCTest

final class KanvasEditorDesignTests: XCTestCase {

    func testOriginal() {
        XCTAssertFalse(KanvasEditorDesign.original.isVerticalMenu, "The result should be false.")
    }
    
    func testVerticalMenu() {
        XCTAssertTrue(KanvasEditorDesign.verticalMenu.isVerticalMenu, "The result should be true.")
    }

}
