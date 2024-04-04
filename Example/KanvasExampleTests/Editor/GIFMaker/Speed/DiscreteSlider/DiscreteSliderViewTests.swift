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

final class DiscreteSliderViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> DiscreteSliderView {
        let view = DiscreteSliderView()
        view.backgroundColor = .darkGray
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 36)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.cellWidth = view.bounds.width / 5
        view.setSelector(at: 0)
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }
    
    func testViewSetupWithIndex() {
        let view = newView()
        view.cellWidth = view.bounds.width / 5
        view.setSelector(at: 2)
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }
    
    func testViewSetupAtLastPosition() {
        let view = newView()
        view.cellWidth = view.bounds.width / 5
        view.setSelector(at: 4)
        FBSnapshotArchFriendlyVerifyView(view, overallTolerance: 0.05)
    }
}
