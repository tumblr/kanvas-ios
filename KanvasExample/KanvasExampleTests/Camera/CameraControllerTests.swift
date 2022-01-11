//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest
import Photos

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
        settings.features.cameraFilters = true
        return newController(delegate: delegate, settings: settings)
    }

    func newController(delegate: CameraControllerDelegate, settings: CameraSettings) -> CameraController {
        let controller = CameraController(settings: settings,
                                          mediaPicker: nil,
                                          stickerProvider: StickerProviderStub(),
                                          analyticsProvider: KanvasAnalyticsStub(),
                                          quickBlogSelectorCoordinator: nil,
                                          tagCollection: nil,
                                          saveDirectory: nil)
        controller.recorderClass = CameraRecorderStub.self
        controller.segmentsHandlerClass = CameraSegmentHandlerStub.self
        controller.captureDeviceAuthorizer = MockCaptureDeviceAuthorizer(initialCameraAccess: .authorized, initialMicrophoneAccess: .authorized, requestedCameraAccessAnswer: .authorized, requestedMicrophoneAccessAnswer: .authorized)
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
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }

    func testSetupWithStopMotionDisabled() {
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.features.ghostFrame = false
        settings.features.cameraFilters = true
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }

    func testSetUpWithGifDefaultModeShouldStartWithGifMode() {
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.defaultMode = .loop
        settings.features.ghostFrame = true
        settings.features.cameraFilters = true
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }

    func testSetUpWithFlashOn() {
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.preferredFlashOption = .on
        settings.features.ghostFrame = true
        settings.features.cameraFilters = true
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }
    
    func testSetUpWithImagePreviewOn() {
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.imagePreviewOption = .on
        settings.features.ghostFrame = true
        settings.features.cameraFilters = true
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }
    
    func testImagePreviewButtonShouldHideOnPhotoMode() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.photo, andClosed: .none)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }
    
    func testImagePreviewButtonShouldHideOnStopMotionMode() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }
    
    func testImagePreviewButtonShouldHideOnGifMode() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.loop, andClosed: .none)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }

    // Can't test `exportStopMotionPhotoAsVideo` because it can't export in tests

    // MARK: - Public functions
    // Can't test `requestAccess`

    // MARK: - ModeSelectorAndShootControllerDelegate
    // Open mode doesn't change UI directly because that is done before the delegate function is called
    // Tap for mode doesn't do anything because it should show preview for photo and gif modes
    func testTapForStopMotionModeShouldHideModeButtonAndAddClipAndShowNextButton() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didTapForMode(.stopMotion)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }

    func testStartLongPressShouldHideUIButFilterSelectorAndShutterButton() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didStartPressingForMode(.stopMotion)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    func testEndLongPressShouldHideModeButtonAndAddClipAndShowNextButtons() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didStartPressingForMode(.stopMotion)
        controller.didEndPressingForMode(.stopMotion)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }

    func testTapAndLongPressShouldAddTwoClipsAndShowNextButton() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        UIView.setAnimationsEnabled(false)
        controller.didOpenMode(.stopMotion, andClosed: .none)
        controller.didTapForMode(.stopMotion)
        controller.didStartPressingForMode(.stopMotion)
        controller.didEndPressingForMode(.stopMotion)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
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
        XCTAssertEqual(videoURL, delegate.media(of: .video).first?.output)
    }

    func testDidFinishExportingImageCallsDelegate() {
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate)
        controller.didFinishExportingImage(image: newImage())
        XCTAssert(delegate.contains(type: .image))
        XCTAssert(!delegate.containsErrors)
    }
    
    func testCameraWithOneMode() {
        let settings = CameraSettings()
        settings.enabledModes = [.photo]
        settings.features.ghostFrame = true
        settings.features.cameraFilters = true
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

    func testCameraWithMediaPickerButton() {
        let settings = CameraSettings()
        settings.enabledModes = [.photo]
        settings.features.mediaPicking = true
        settings.features.cameraFilters = true
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

    func testCameraWithFiltersOpenHidesMediaPickerButton() {
        let settings = CameraSettings()
        settings.enabledModes = [.photo]
        settings.features.mediaPicking = true
        settings.features.cameraFilters = true
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate, settings: settings)
        UIView.setAnimationsEnabled(false)
        controller.didTapVisibilityButton(visible: true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    func testCameraInNormalModeShowsMediaPickerButton() {
        let settings = CameraSettings()
        settings.enabledModes = [.normal]
        settings.features.mediaPicking = true
        settings.features.cameraFilters = true
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

    func testCameraInStitchModeDoesNotShowMediaPickerButton() {
        let settings = CameraSettings()
        settings.enabledModes = [.stitch]
        settings.features.mediaPicking = true
        settings.features.cameraFilters = true
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

    func testCameraInGIFModeDoesNotShowMediaPickerButton() {
        let settings = CameraSettings()
        settings.enabledModes = [.gif]
        settings.features.mediaPicking = true
        settings.features.cameraFilters = true
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

    func testCameraClosingFiltersInStitchModeDoesNotShowMediaPickerAgain() {
        let settings = CameraSettings()
        settings.enabledModes = [.stitch]
        settings.features.mediaPicking = true
        settings.features.cameraFilters = true
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate, settings: settings)
        UIView.setAnimationsEnabled(false)
        controller.didTapVisibilityButton(visible: true)
        controller.didTapVisibilityButton(visible: false)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view, tolerance: 0.05)
    }

    // Can't test `dismissButtonPressed` because it requires presenting and dismissing preview controller.
    
    func testCameraWithTopButtonsSwapped() {
        let settings = CameraSettings()
        settings.enabledModes = [.photo]
        settings.topButtonsSwapped = true
        let delegate = newDelegateStub()
        let controller = newController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }
}

final class CameraControllerDelegateStub: CameraControllerDelegate {

    func openAppSettings(completion: ((Bool) -> ())?) {

    }

    func tagButtonPressed() {

    }

    func editorDismissed() {

    }

    func didDismissWelcomeTooltip() {
        
    }
    
    func cameraShouldShowWelcomeTooltip() -> Bool {
        return false
    }

    func editorDismissed(_ cameraController: CameraController) {
        
    }
    
    func didDismissColorSelectorTooltip() {
        
    }
    
    func editorShouldShowColorSelectorTooltip() -> Bool {
        return false
    }
    
    func didEndStrokeSelectorAnimation() {
        
    }
    
    func editorShouldShowStrokeSelectorAnimation() -> Bool {
        return false
    }
    
    func didBeginDragInteraction() {
        
    }
    
    func didEndDragInteraction() {
        
    }
    
    func getQuickPostButton() -> UIView {
        return UIView()
    }
    
    func getBlogSwitcher() -> UIView {
        return UIView()
    }

    var results: [Result<KanvasMedia?, Error>] = []
    
    var dismissCalled = false

    func media(of type: MediaType) -> [KanvasMedia] {
        return results.compactMap({ result in
            switch result {
            case .success(let media):
                if media?.type == type {
                    return media
                } else {
                    return nil
                }
            case .failure:
                return nil
            }
        })
    }

    func contains(type: MediaType) -> Bool {
        return results.contains(where: { result in
            switch result {
            case .success(let media):
                return media?.type == type
            case .failure:
                return false
            }
        })
    }

    var containsErrors: Bool {
        return errors.contains(where: { $0 != nil })
    }

    var errors: [Error?] {
        return results.map({ result in
            switch result {
            case .success:
                return nil
            case .failure(let error):
                return error
            }
        })
    }

    func didCreateMedia(_ cameraController: CameraController, media: [Result<KanvasMedia?, Error>], exportAction: KanvasExportAction) {
        results = media
    }

    func dismissButtonPressed(_ cameraController: CameraController) {
        dismissCalled = true
    }
}
