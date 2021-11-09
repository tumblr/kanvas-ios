//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest
import FBSnapshotTestCase
@testable import Kanvas

class KanvasFontsTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testDrawerFont() {
        let label = newLabelView()
        let drawer = KanvasFonts.Drawer(textSelectedFont: .guavaMedium(), textUnselectedFont: .guavaMedium())
        label.font = drawer.textSelectedFont
        FBSnapshotVerifyView(label, tolerance: 0.05)
    }
    
    func testPermissionsFont() {
        let label = newLabelView()
        let permissions = KanvasFonts.CameraPermissions(titleFont: .guavaMedium(), descriptionFont: .guavaMedium(), buttonFont: .guavaMedium())
        label.font = permissions.titleFont
        FBSnapshotVerifyView(label, tolerance: 0.05)
    }
    
    func testPadding() {
        let font = KanvasFonts.shared.postLabelFont
        
        let padding = KanvasFonts.Padding(topMargin: 10, leftMargin: 10, extraVerticalPadding: 10, extraHorizontalPadding: 10)
        XCTAssertEqual(padding.topMargin, 10)
        
        let paddingAdjustment = KanvasFonts.shared.paddingAdjustment?(font)
        XCTAssertNil(paddingAdjustment)
    }
    
    func newLabelView() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = "Test"
        return label
    }
}
