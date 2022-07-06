//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ColorDropTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newColorDrop() -> ColorDrop {
        let colorDrop = ColorDrop()
        colorDrop.frame = CGRect(x: 0, y: 0, width: ColorDrop.defaultWidth, height: ColorDrop.defaultHeight)
        colorDrop.innerColor = .tumblrBrightBlue
        return colorDrop
    }
    
    func testViewSetup() {
        let imageView = newColorDrop()
        FBSnapshotArchFriendlyVerifyView(imageView)
    }
    
}
