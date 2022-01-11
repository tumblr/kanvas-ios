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

final class TimeIndicatorTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> TimeIndicator {
        let view = TimeIndicator()
        view.frame = CGRect(x: 0, y: 0, width: TimeIndicator.width, height: TimeIndicator.height)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.text = "0:02"
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }
    
}
