//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest
import AVFoundation
import UIKit
import FBSnapshotTestCase
@testable import KanvasCamera

final class OptionViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func testNewButton() {
        if let image = KanvasCameraImages.FlashOffImage {
            let button = OptionView(image: image)
            button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            FBSnapshotVerifyView(button)
        }
        else {
            XCTFail("Bundle image not found")
        }
    }

}
