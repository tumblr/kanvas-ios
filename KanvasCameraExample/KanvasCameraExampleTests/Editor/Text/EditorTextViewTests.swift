//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class EditorTextViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> EditorTextView {
        let textViewSettings = EditorTextView.Settings(fontSelectorUsesFont: false)
        let view = EditorTextView(settings: textViewSettings)
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.showConfirmButton(true)
        FBSnapshotVerifyView(view)
    }
    
}
