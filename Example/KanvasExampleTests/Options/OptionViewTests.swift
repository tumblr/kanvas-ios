//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
import UIKit
import XCTest

final class OptionViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func testNewButton() {
        if let image = KanvasImages.flashOffImage {
            let button = OptionView(image: image, backgroundColor: .clear)
            button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            FBSnapshotArchFriendlyVerifyView(button)
        }
        else {
            XCTFail("Bundle image not found")
        }
    }

    func testTouchOutsideOfButton() {
        guard let image = KanvasImages.flashOffImage else {
            XCTFail("Bundle image not found")
            return
        }

        let button = OptionView(image: image, backgroundColor: .clear)
        button.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        view.addSubview(button)
        let touchPoint = CGPoint(x: 5, y: 5)
        let touched = button.point(inside: touchPoint, with: nil)
        XCTAssertTrue(touched, "Button did not receive touch")
    }
}
