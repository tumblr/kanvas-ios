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
        let controller = ThumbnailCollectionController()
        let delegate = ThumbnailCollectionControllerDelegateStub()
        controller.delegate = delegate
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: ThumbnailCollectionCell.cellHeight)
        controller.view.backgroundColor = .black
        controller.view.setNeedsDisplay()
        
        FBSnapshotVerifyView(controller.view)
    }
}

private class ThumbnailCollectionControllerDelegateStub: ThumbnailCollectionControllerDelegate {
    func getMediaDuration() -> TimeInterval? {
        return TimeInterval(30)
    }
    
    func getThumbnail(at timestamp: TimeInterval) -> UIImage? {
        return KanvasCameraImages.flashOnImage
    }
    
    func didBeginScrolling() {
        
    }
    
    func didScroll() {
        
    }
    
    func didEndScrolling() {
        
    }
}
