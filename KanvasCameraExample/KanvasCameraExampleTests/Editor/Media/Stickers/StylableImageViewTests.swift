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

final class StylableImageViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        return view
    }
    
    func testImageViewWithExampleImage() {
        let view = newView()
        let imageView = StylableImageView(image: KanvasCameraImages.gradientImage)
        imageView.add(into: view)
        FBSnapshotVerifyView(imageView)
    }
}
