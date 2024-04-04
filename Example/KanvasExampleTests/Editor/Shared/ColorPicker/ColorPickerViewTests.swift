//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
import Foundation
import UIKit
import XCTest

final class ColorPickerViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> ColorPickerView {
        let view = ColorPickerView()
        view.frame = CGRect(x: 0, y: 0,
                            width: 120,
                            height: 40)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }
}
