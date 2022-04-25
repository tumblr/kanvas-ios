//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class TrimControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> TrimController {
        let controller = TrimController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: TrimView.height)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testTrimControllerView() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.showView(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(controller.view)
    }
}
