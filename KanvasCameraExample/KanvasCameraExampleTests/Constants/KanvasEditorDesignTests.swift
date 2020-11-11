//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class KanvasEditorDesignTests: XCTestCase {

    func testDefaultDesign() {
        XCTAssertFalse(KanvasEditorDesign.defaultDesign.isRedesign, "The result should be false.")
    }
    
    func testRedesign() {
        XCTAssertTrue(KanvasEditorDesign.redesign.isRedesign, "The result should be true.")
    }

}
