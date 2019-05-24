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

final class EditionMenuCollectionControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCameraSettings() -> CameraSettings {
        let settings = CameraSettings()
        settings.features.editorFilters = true
        settings.features.editorMedia = true
        return settings
    }
    
    func newViewController() -> EditionMenuCollectionController {
        let settings = newCameraSettings()
        let controller = EditionMenuCollectionController(settings: settings)
        controller.view.frame = CGRect(x: 0, y: 0, width: 600, height: 600)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testCollectionControllerView() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.showView(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
}
