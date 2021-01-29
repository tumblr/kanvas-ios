//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class KanvasCameraCustomUITests: XCTestCase {

    // test that values are set by KanvasCameraCustomUI as part of the example app
    func testDefaults() {
        XCTAssertEqual(KanvasCameraFonts.shared.editorFonts, KanvasCameraCustomUI.shared.cameraFonts().editorFonts)
        XCTAssertEqual(KanvasCameraColors.shared.backgroundColors, KanvasCameraCustomUI.shared.cameraColors().backgroundColors)
    }
}
