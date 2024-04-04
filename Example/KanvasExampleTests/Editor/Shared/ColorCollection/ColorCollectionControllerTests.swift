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

final class ColorCollectionControllerTests: FBSnapshotTestCase {
    
    var colors: [UIColor] = []
    
    override func setUp() {
        super.setUp()
        
        colors = [
            .tumblrBrightBlue,
            .tumblrBrightRed,
            .tumblrBrightOrange
        ]
        
        self.recordMode = false
    }
    
    func newViewController() -> ColorCollectionController {
        let controller = ColorCollectionController()
        controller.view.frame = CGRect(x: 0, y: 0,
                                       width: ColorCollectionCell.width * CGFloat(colors.count),
                                       height: ColorCollectionCell.height)
        controller.addColors(colors)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testCollectionControllerView() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.showView(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(controller.view)
    }
}
