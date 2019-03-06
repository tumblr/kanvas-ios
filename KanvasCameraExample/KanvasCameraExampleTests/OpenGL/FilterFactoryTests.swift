//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

class FilterFactoryTests: XCTestCase {

    func testCreateFilter() {
        let glContext = EAGLContext(api: .openGLES3) ?? nil
        _ = FilterFactory.createFilter(type: .lego, glContext: glContext)
    }

    func testFilterType() {
        XCTAssertEqual(FilterType.lego.key(), "lego")
    }

}
