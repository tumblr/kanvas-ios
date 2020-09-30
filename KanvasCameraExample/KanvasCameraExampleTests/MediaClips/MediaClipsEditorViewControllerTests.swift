//
// Created by Tony Cheng on 8/21/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class MediaClipsEditorViewControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newViewController(delegate: MediaClipsEditorDelegate = MediaClipsEditorViewControllerDelegateStub()) -> MediaClipsEditorViewController {
        let viewController = MediaClipsEditorViewController()
        viewController.delegate = delegate
        viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        viewController.view.layoutIfNeeded()
        return viewController
    }

    func newMediaClip() -> MediaClip? {
        var mediaClip: MediaClip? = nil
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            mediaClip = MediaClip(representativeFrame: image, overlayText: "00:02", lastFrame: image)
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

    func testMoveClipCallsDelegate() {
        guard let clip1 = newMediaClip(), let clip2 = newMediaClip() else { return }
        let delegate = MediaClipsEditorViewControllerDelegateStub()
        let viewController = newViewController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        viewController.addNewClip(clip1)
        viewController.addNewClip(clip2)
        viewController.mediaClipWasMoved(from: 0, to: 1)
        UIView.setAnimationsEnabled(true)
        XCTAssert(delegate.movedWasCalled, "Move failed to call delegate")
    }
    
    func testDragStartedFinishedDelegate() {
        let delegate = MediaClipsEditorViewControllerDelegateStub()
        let viewController = newViewController(delegate: delegate)
        viewController.mediaClipStartedMoving()
        XCTAssertTrue(delegate.dragStarted, "Drag started delegate method was not called")
        viewController.mediaClipFinishedMoving()
        XCTAssertTrue(delegate.dragFinished, "Drag finished delegate method was not called")
    }
}

final class MediaClipsEditorViewControllerDelegateStub: MediaClipsEditorDelegate {
    
    var movedWasCalled = false
    var dragStarted = false
    var dragFinished = false
    
    func mediaClipWasAdded(at index: Int) {
        
    }
    
    func mediaClipWasDeleted(at index: Int) {
        
    }
    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int) {
        movedWasCalled = true
    }
    
    func mediaClipStartedMoving() {
        dragStarted = true
    }
    
    func mediaClipFinishedMoving() {
        dragFinished = true
    }
    
    func nextButtonWasPressed() {
        
    }
}
