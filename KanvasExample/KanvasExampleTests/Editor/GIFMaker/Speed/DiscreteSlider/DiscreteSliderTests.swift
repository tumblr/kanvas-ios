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

final class DiscreteSliderTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newSlider() -> DiscreteSlider {
        let items: [Float] = [0.5, 1, 1.5, 2, 3, 4]
        let initialIndex: Int = 1
        let slider = DiscreteSlider(items: items, initialIndex: initialIndex)
        slider.view.frame = CGRect(x: 0, y: 0, width: 320, height: 36)
        slider.view.setNeedsDisplay()
        return slider
    }
    
    func testSliderView() {
        let slider = newSlider()
        FBSnapshotVerifyView(slider.view, tolerance: 0.05)
    }
}
