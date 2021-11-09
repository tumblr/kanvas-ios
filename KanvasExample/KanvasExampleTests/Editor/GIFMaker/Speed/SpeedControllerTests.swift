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

final class SpeedControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newViewController() -> SpeedController {
        let controller = SpeedController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: SpeedView.height)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testSpeedControllerView() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.showView(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }
}
