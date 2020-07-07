//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest
import FBSnapshotTestCase
@testable import KanvasCamera

class KanvasCameraFontsTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testDrawerFont() {
        let label = newLabelView()
        label.font = KanvasCameraFonts.shared.drawer.textSelectedFont
        FBSnapshotVerifyView(label)
    }
    
    func testPermissionsFont() {
        let label = newLabelView()
        label.font = KanvasCameraFonts.shared.permissions.titleFont
        FBSnapshotVerifyView(label)
    }
    
    func testPadding() {
        let font = KanvasCameraFonts.shared.postLabelFont
        let padding = KanvasCameraFonts.shared.paddingAdjustment?(font)
        XCTAssertNil(padding)
    }
    
    func newLabelView() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = "Test"
        return label
    }
}
