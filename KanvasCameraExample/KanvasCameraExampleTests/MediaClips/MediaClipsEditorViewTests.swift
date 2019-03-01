//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class MediaClipsEditorViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newEditorView() -> MediaClipsEditorView {
        let editorView = MediaClipsEditorView()
        editorView.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return editorView
    }

}
