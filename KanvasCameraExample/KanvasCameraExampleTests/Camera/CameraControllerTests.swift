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

final class CameraControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newVideo() -> URL? {
        return Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4")
    }

    func newImage() -> UIImage? {
        return Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap { UIImage(contentsOfFile: $0) }
    }

    func newDelegateStub() -> CameraControllerDelegateStub {
        return CameraControllerDelegateStub()
    }

    func newController(delegate: CameraControllerDelegate) -> CameraController {
        let settings = CameraSettings()
        settings.features.ghostFrame = true
        return newController(delegate: delegate, settings: settings)
    }

    func newController(delegate: CameraControllerDelegate, settings: CameraSettings) -> CameraController {
        let controller = CameraController(settings: settings, recorderClass: CameraRecorderStub.self, segmentsHandlerClass: CameraSegmentHandlerStub.self, analyticsProvider: KanvasCameraAnalyticsStub())
        controller.delegate = delegate
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        UIView.setAnimationsEnabled(false)
        // For media clips collection
        controller.view.setNeedsDisplay()
        controller.view.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
        return controller
    }

    // MARK: - Setting
    func testSetUpWithAllOptionsAndModesShouldStartWithFlashOffAndStopMotionMode() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        FBSnapshotVerifyView(controller.view)
    }

    func testSetupWithStopMotionDisabled() {
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.features.ghostFrame = false
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

    func testSetUpWithGifDefaultModeShouldStartWithGifMode() {
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.defaultMode = .gif
        settings.features.ghostFrame = true
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

    func testSetUpWithoutStopMotionModeShouldStartWithPhotoMode() {
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.enableStopMotionMode = false
        settings.features.ghostFrame = true
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

    func testSetUpWithFlashOn() {
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.preferredFlashOption = .on
        settings.features.ghostFrame = true
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testSetUpWithImagePreviewOn() {
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.imagePreviewOption = .on
        settings.features.ghostFrame = true
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testImagePreviewButtonShouldHideOnPhotoMode() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.photo, andClosed: .none)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testImagePreviewButtonShouldAppearOnStopMotionMode() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testImagePreviewButtonShouldAppearOnGifMode() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.gif, andClosed: .none)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    // Can't test `exportStopMotionPhotoAsVideo` because it can't export in tests

    // MARK: - Public functions
    // Can't test `requestAccess`

    // MARK: - ModeSelectorAndShootControllerDelegate
    // Open mode doesn't change UI directly because that is done before the delegate function is called
    // Tap for mode doesn't do anything because it should show preview for photo and gifd modes
    func testTapForStopMotionModeShouldHideModeButtonAndAddClipAndShowUndoNextButtons() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didTapForMode(.stopMotion)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    func testStartLongPressShouldHideUIButButton() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didStartPressingForMode(.stopMotion)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    func testEndLongPressShouldHideModeButtonAndAddClipAndShowUndoNextButtons() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didStartPressingForMode(.stopMotion)
        controller.didEndPressingForMode(.stopMotion)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    func testTapAndLongPressShouldAddTwoClipsAndShowUndoNextButtons() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didTapForMode(.stopMotion)
        controller.didStartPressingForMode(.stopMotion)
        controller.didEndPressingForMode(.stopMotion)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    // MARK: - CameraViewDelegate
    func testCloseButtonPressedCallsDelegate() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.closeButtonPressed()
        UIView.setAnimationsEnabled(true)
        XCTAssert(delegate.dismissCalled)
    }

    func testUndoButtonPressedShouldDeleteLastClip() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didTapForMode(.stopMotion)
        controller.didStartPressingForMode(.stopMotion)
        controller.didEndPressingForMode(.stopMotion)
        controller.undoButtonPressed()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    func testUndoButtonPressedWhenOneClipShouldDisappearUndoAndNextAndShowModeButton() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didTapForMode(.stopMotion)
        controller.undoButtonPressed()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    // Can't test `nextButtonPressed` without controller hierarchy

    // MARK: - OptionsCollectionControllerDelegate
    // Can't test `optionSelected` because they don't directly change UI or variables,
    // but are passed on to other classes

    // MARK: - MediaClipsEditorDelegate
    // Can't test `mediaClipWasDeleted` because is has no impact except on the segment handler.

    // MARK: - CameraPreviewControllerDelegate
    func testDidFinishExportingVideoCallsDelegate() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        let videoURL = newVideo()
        controller.didFinishExportingVideo(url: videoURL)
        XCTAssertEqual(videoURL, delegate.videoURL)
    }

    func testDidFinishExportingImageCallsDelegate() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        controller.didFinishExportingImage(image: newImage())
        XCTAssert(delegate.imageCreatedCalled)
        XCTAssert(!delegate.creationError)
    }
    
    func testCameraWithOneMode() {
        let settings = CameraSettings()
        settings.enabledModes = [.photo]
        settings.features.ghostFrame = true
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

    // Can't test `dismissButtonPressed` because it requires presenting and dismissing preview controller.
}

final class CameraControllerDelegateStub: CameraControllerDelegate {

    func didDismissWelcomeTooltip() {
    }
    
    func didDismissCreationTooltip() {
    }
    
    func cameraShouldShowWelcomeTooltip() -> Bool {
        return false
    }
    
    func cameraShouldShowCreationTooltip() -> Bool {
        return false
    }

    var dismissCalled = false
    var videoURL: URL? = nil
    var imageCreatedCalled = false
    var creationError = false
    var creationEmpty = false

    func didCreateMedia(media: KanvasCameraMedia?, error: Error?) {
        switch (media, error) {
        case (.none, .none): creationEmpty = true
        case (_, .some): creationError = true
        case (.some(.image(_)), _): imageCreatedCalled = true
        case (.some(.video(let url)), _): videoURL = url
        }
    }

    func dismissButtonPressed() {
        dismissCalled = true
    }
}
