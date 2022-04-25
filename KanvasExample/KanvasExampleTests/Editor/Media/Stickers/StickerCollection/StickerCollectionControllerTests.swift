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

final class StickerCollectionControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> StickerCollectionController {
        let controller = StickerCollectionController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testStickerCollectionControllerView() {
        let controller = newViewController()
        FBSnapshotArchFriendlyVerifyView(controller.view)
    }
}
