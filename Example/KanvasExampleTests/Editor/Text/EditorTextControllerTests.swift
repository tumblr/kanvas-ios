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

final class EditorTextControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> EditorTextController {
        let editorSettings = EditorTextController.Settings(textViewSettings: EditorTextView.Settings(fontSelectorUsesFont: false, resizesFonts: true))
        let controller = EditorTextController(settings: editorSettings)
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testEditorTextControllerView() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.showView(true)
        controller.showConfirmButton(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotArchFriendlyVerifyView(controller.view)
    }
}
