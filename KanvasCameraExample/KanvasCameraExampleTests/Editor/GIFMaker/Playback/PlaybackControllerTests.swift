//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class PlaybackControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newViewController() -> PlaybackController {
        let controller = PlaybackController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: PlaybackView.height)
        controller.view.setNeedsDisplay()
        controller.viewDidLayoutSubviews()
        return controller
    }
    
    func testPlaybackControllerView() {
        let controller = newViewController()
        FBSnapshotVerifyView(controller.view)
    }
}
