//
// Created by Tony Cheng on 8/21/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
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
