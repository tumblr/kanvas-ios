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

final class ConicalGradientLayerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func testTumblrColorsGradient() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let gradient = ConicalGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [.tumblrBrightRed,
                          .tumblrBrightPink,
                          .tumblrBrightOrange,
                          .tumblrBrightYellow,
                          .tumblrBrightGreen,
                          .tumblrBrightBlue,
                          .tumblrBrightPurple,
                          .tumblrBrightRed]
        view.layer.addSublayer(gradient)
        FBSnapshotVerifyView(view)
    }
    
}
