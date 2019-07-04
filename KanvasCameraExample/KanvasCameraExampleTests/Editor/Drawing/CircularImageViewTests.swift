//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class CircularImageViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCircularImageView() -> CircularImageView {
        let imageView = CircularImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: CircularImageView.size, height: CircularImageView.size)
        imageView.backgroundColor = .tumblrBrightBlue
        return imageView
    }
    
    func testViewSetup() {
        let imageView = newCircularImageView()
        FBSnapshotVerifyView(imageView)
    }
    
}
