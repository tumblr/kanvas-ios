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

final class MainTextViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        return view
    }
    
    func testTextViewWithText() {
        let view = newView()
        let textView = MainTextView()
        textView.add(into: view)
        textView.text = "Example"
        textView.textAlignment = .center
        textView.font = .fairwater(fontSize: 48)
        FBSnapshotArchFriendlyVerifyView(textView)
    }
}
