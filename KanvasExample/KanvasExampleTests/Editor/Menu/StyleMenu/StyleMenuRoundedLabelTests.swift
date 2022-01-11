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

final class StyleMenuRoundedLabelTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newLabel() -> StyleMenuRoundedLabel {
        let label = StyleMenuRoundedLabel()
        label.frame = CGRect(x: 0, y: 0, width: 60, height: StyleMenuRoundedLabel.height)
        label.textColor = .white
        label.backgroundColor = .black
        return label
    }
    
    func testLabel() {
        let label = newLabel()
        label.text = "Test"
        label.layoutIfNeeded()
        FBSnapshotVerifyView(label, tolerance: 0.05)
    }
}
