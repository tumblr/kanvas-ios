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

final class SliderViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newSliderView() -> SliderView {
        let sliderView = SliderView()
        sliderView.frame = CGRect(x: 0, y: 0, width: 34, height: 130)
        return sliderView
    }
    
    func testSliderView() {
        let sliderView = newSliderView()
        FBSnapshotVerifyView(sliderView)
    }
}
