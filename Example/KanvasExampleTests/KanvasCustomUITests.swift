//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
#if SWIFT_PACKAGE
import KanvasExample
#endif
import Foundation
import XCTest

final class KanvasCustomUITests: XCTestCase {

    // test that values are set by KanvasCustomUI as part of the example app
    func testDefaults() {
        XCTAssertEqual(KanvasFonts.shared.editorFonts, KanvasCustomUI.shared.cameraFonts().editorFonts)
        XCTAssertEqual(KanvasColors.shared.backgroundColors, KanvasCustomUI.shared.cameraColors().backgroundColors)
    }
}
