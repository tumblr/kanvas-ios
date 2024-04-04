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

final class FilterSettingsControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> FilterSettingsController {
        let controller = FilterSettingsController(settings: CameraSettings())
        controller.view.frame = CGRect(x: 0, y: 0, width: 600, height: FilterSettingsView.height)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testHideCollection() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.didTapVisibilityButton()
        controller.didTapVisibilityButton()
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(controller.view)
    }

    func testShowCollection() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.didTapVisibilityButton()
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(controller.view, overallTolerance: 0.05)
    }
}
