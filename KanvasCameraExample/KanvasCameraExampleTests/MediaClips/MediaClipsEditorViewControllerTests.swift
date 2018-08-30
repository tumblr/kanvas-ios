//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest
import AVFoundation
import UIKit
import FBSnapshotTestCase
@testable import KanvasCamera

final class MediaClipsEditorViewControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newViewController() -> MediaClipsEditorViewController {
        let viewController = MediaClipsEditorViewController()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        viewController.view.layoutIfNeeded()
        return viewController
    }

    func newMediaClip() -> MediaClip? {
        var mediaClip: MediaClip? = nil
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            mediaClip = MediaClip(representativeFrame: image, overlayText: "00:02")
        }
        if mediaClip == nil {
            XCTFail("Media clip was not loaded")
        }
        return mediaClip
    }

    func testAddNewClip() {
        guard let clip = newMediaClip() else { return }
        let viewController = newViewController()
        viewController.addNewClip(clip)
        XCTAssert(viewController.hasClips, "Editor Controller has no clips")
    }

    func testUndo() {
        guard let clip = newMediaClip() else { return }
        let viewController = newViewController()
        UIView.setAnimationsEnabled(false)
        viewController.addNewClip(clip)
        viewController.undo()
        UIView.setAnimationsEnabled(true)
        XCTAssert(!viewController.hasClips, "Undo failed, clips still remain")
    }

}
