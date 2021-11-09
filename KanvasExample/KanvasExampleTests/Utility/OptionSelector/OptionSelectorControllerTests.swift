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

final class OptionSelectorControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newViewController() -> OptionSelectorController {
        let options: [OptionSelectorItem] = [PlaybackOption.loop, PlaybackOption.rebound, PlaybackOption.reverse]
        let controller = OptionSelectorController(options: options)
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: OptionSelectorView.height)
        controller.view.setNeedsDisplay()
        controller.viewDidLayoutSubviews()
        return controller
    }
    
    func testControllerView() {
        let controller = newViewController()
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }
}
