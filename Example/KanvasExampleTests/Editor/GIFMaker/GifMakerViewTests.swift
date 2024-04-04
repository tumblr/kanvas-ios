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

final class GifMakerViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> GifMakerView {
        let view = GifMakerView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.showConfirmButton(true)
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }
    
    func testRevertButton() {
        let view = newView()
        view.toggleRevertButton(true)
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }
    
}
