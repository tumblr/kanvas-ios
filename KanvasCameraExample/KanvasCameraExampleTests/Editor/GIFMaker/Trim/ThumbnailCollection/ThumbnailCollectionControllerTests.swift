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

final class ThumbnailCollectionControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func testThumbnailCollectionControllerView() {
        guard let exampleImage = KanvasCameraImages.gradientImage else {
            XCTFail("Example image not found")
            return
        }
        let controller = ThumbnailCollectionController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: TrimView.height)
        controller.setThumbnails([exampleImage, exampleImage, exampleImage])
        controller.view.setNeedsDisplay()
        
        FBSnapshotVerifyView(controller.view)
    }
}
