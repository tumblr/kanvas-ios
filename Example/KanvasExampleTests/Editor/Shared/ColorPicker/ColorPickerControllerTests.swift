//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
import Foundation
import UIKit
import XCTest

final class ColorPickerControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> ColorPickerController {
        let controller = ColorPickerController()
        controller.view.frame = CGRect(x: 0, y: 0,
                                       width: 128,
                                       height: 40)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testSelectorControllerView() {
        let controller = newViewController()
        FBSnapshotArchFriendlyVerifyView(controller.view, overallTolerance: 0.05)
    }
}
