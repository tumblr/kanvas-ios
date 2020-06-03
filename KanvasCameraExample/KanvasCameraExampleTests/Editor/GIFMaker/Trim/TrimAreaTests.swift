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

final class TrimAreaTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> TrimArea {
        let view = TrimArea()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: TrimArea.height)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }
    
}
