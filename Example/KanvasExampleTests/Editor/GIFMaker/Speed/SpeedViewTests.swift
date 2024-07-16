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

final class SpeedViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newView() -> SpeedView {
        let view = SpeedView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: SpeedView.height)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.setLabelText("1x")
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }
}
