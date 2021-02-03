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
        let imageView = StylableImageView(id: "id", image: KanvasImages.gradientImage)
        imageView.add(into: view)
        FBSnapshotVerifyView(imageView)
    }
    
    func testHitInsideShape() {
        let imageView = StylableImageView(id: "id", image: KanvasImages.gradientImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let point = imageView.bounds.center
        let wasHitInside = imageView.hitInsideShape(point: point)
        XCTAssertTrue(wasHitInside, "The method should return true since the hit was done in a visible area of the image.")
    }
    
    func testHitOutsideShape() {
        let imageView = StylableImageView(id: "id", image: KanvasImages.gradientImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let point = CGPoint(x: 190, y: 190)
        let wasHitInside = imageView.hitInsideShape(point: point)
        XCTAssertFalse(wasHitInside, "The method should return false since the hit was done in an empty area of the image.")
    }
}
