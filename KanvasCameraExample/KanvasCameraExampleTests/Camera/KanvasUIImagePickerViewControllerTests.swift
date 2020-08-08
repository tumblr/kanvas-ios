//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
@testable import KanvasCamera

final class KanvasUIImagePickerViewControllerTests: XCTestCase {

    func testPrefersStatusBarHidden() {
        let picker = MediaPickerViewController()
        guard let c = picker.children.first as? UIImagePickerController else {
            XCTFail("No picker")
            return
        }
        XCTAssert(c.prefersStatusBarHidden == false)
    }

    func testChildForStatusBarHidden() {
        let picker = MediaPickerViewController()
        guard let c = picker.children.first as? UIImagePickerController else {
            XCTFail("No picker")
            return
        }
        XCTAssert(c.childForStatusBarHidden == nil)
    }
}
