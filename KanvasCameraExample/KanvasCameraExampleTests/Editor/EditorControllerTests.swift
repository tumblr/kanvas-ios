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

class MediaExporterStub: MediaExporting {
    var filterType: FilterType = .passthrough
    var imageOverlays: [CGImage] = []

    var exportImageCalled: Bool = false
    var exportFramesCalled: Bool = false
    var exportVideoCalled: Bool = false

    required init(settings: CameraSettings) {

    }

    func export(image: UIImage, time: TimeInterval, completion: (UIImage?, Error?) -> Void) {
        exportImageCalled = true
        completion(image, nil)
    }

    func export(frames: [MediaFrame], completion: @escaping ([MediaFrame]) -> Void) {
        exportFramesCalled = true
        completion(frames)
    }

    func export(video url: URL, mediaInfo: MediaInfo, completion: @escaping (URL?, Error?) -> Void) {
        exportVideoCalled = true
        completion(url, nil)
    }
}

final class GIFEncoderStub: GIFEncoder {

    var encodeGIFCalled = false

    func encode(video url: URL, loopCount: Int, framesPerSecond: Int, completion: @escaping (URL?) -> Void) {
        encodeGIFCalled = true
        completion(url)
    }

    func encode(frames: [(image: UIImage, interval: TimeInterval)], loopCount: Int, completion: @escaping (URL?) -> Void) {
        encodeGIFCalled = true
        let gifURL = Bundle(for: type(of: self)).url(forResource: "colors", withExtension: "gif")
        completion(gifURL)
    }
}

final class EditorControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func getCameraSettings() -> CameraSettings {
        let settings = CameraSettings()
        settings.features.editor = true
        settings.features.gifs = true
        settings.features.editorFilters = true
        settings.features.editorText = true
        settings.features.editorMedia = true
        settings.features.editorDrawing = true
        return settings
    }
    
    func getAllSegments() -> [CameraSegment] {
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }),
            let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            return [
                CameraSegment.image(image, videoURL, nil, mediaInfo),
                CameraSegment.video(videoURL, mediaInfo),
                CameraSegment.image(image, videoURL, nil, mediaInfo),
                CameraSegment.video(videoURL, mediaInfo)
            ]
        }
        return []
    }
    
    func getVideoSegments() -> [CameraSegment] {
        if let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            return [
                CameraSegment.video(videoURL, mediaInfo),
                CameraSegment.video(videoURL, mediaInfo)
            ]
        }
        return []
    }

    func getPhotoSegment() -> [CameraSegment] {
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }) {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            return [
                CameraSegment.image(image, nil, nil, mediaInfo)
            ]
        }
        return []
    }

    func getLivePhotoSegment() -> [CameraSegment] {
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }),
            let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            return [
                CameraSegment.image(image, videoURL, nil, mediaInfo)
            ]
        }
        return []
    }
    
    func getPhotoSegments() -> [CameraSegment] {
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }),
            let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            return [
                CameraSegment.image(image, videoURL, nil, mediaInfo),
                CameraSegment.image(image, videoURL, nil, mediaInfo)
            ]
        }
        return []
    }
    
    func newViewController(settings: CameraSettings? = nil, segments: [CameraSegment], delegate: EditorControllerDelegate? = nil, assetsHandler: AssetsHandlerType? = nil, cameraMode: CameraMode? = nil, analyticsProvider: KanvasCameraAnalyticsProvider? = nil) -> EditorViewController {
        let cameraSettings = settings ?? getCameraSettings()
        let handler = assetsHandler ?? AssetsHandlerStub()
        let analytics = analyticsProvider ?? KanvasCameraAnalyticsStub()
        let viewController = EditorViewController(settings: cameraSettings, segments: segments, assetsHandler: handler, exporterClass: MediaExporterStub.self, gifEncoderClass: GIFEncoderStub.self, cameraMode: cameraMode, stickerProvider: StickerProviderStub(), analyticsProvider: analytics, quickBlogSelectorCoordinator: nil)
        viewController.delegate = delegate ?? newDelegateStub()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return viewController
    }
    
    func newDelegateStub() -> EditorControllerDelegateStub {
        let stub = EditorControllerDelegateStub()
        return stub
    }
    
    func newAssetHandlerStub() -> AssetsHandlerStub {
        return AssetsHandlerStub()
    }
    
    func testSetUp() {
        let segments = getAllSegments()
        let viewController = newViewController(segments: segments)
        FBSnapshotVerifyView(viewController.view)
    }
    
    func testShowLoading() {
        let segments = getAllSegments()
        let viewController = newViewController(segments: segments)
        UIView.setAnimationsEnabled(false)
        viewController.hideLoading()
        viewController.showLoading()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
    }
    
    func testHideLoading() {
        let segments = getAllSegments()
        let viewController = newViewController(segments: segments)
        UIView.setAnimationsEnabled(false)
        viewController.showLoading()
        viewController.hideLoading()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
    }
    
    func testConfirmPhoto() {
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let handler = newAssetHandlerStub()
        let viewController = newViewController(segments: segments, delegate: delegate, assetsHandler: handler)
        UIView.setAnimationsEnabled(false)
        viewController.didTapConfirmButton()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
        XCTAssert(!handler.mergeAssetsCalled, "Handler merge assets function called")
        XCTAssert(delegate.imageExportCalled, "Delegate image export function not called")
    }
    
    func testConfirmPhotos() {
        let segments = getPhotoSegments()
        let delegate = newDelegateStub()
        let handler = newAssetHandlerStub()
        let viewController = newViewController(segments: segments, delegate: delegate, assetsHandler: handler)
        UIView.setAnimationsEnabled(false)
        viewController.didTapConfirmButton()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
        XCTAssert(!handler.mergeAssetsCalled, "Handler merge assets function not called")
        XCTAssert(delegate.framesExportCalled, "Delegate frames export function not called")
    }
    
    func testConfirmPhotoAsVideoInStopMotionMode() {
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let settings = getCameraSettings()
        settings.exportStopMotionPhotoAsVideo = true
        let handler = newAssetHandlerStub()
        let viewController = newViewController(settings: settings, segments: segments, delegate: delegate, assetsHandler: handler, cameraMode: .stopMotion)
        viewController.didTapConfirmButton()
        XCTAssertTrue(!handler.mergeAssetsCalled, "Handler merge assets function called")
        XCTAssertTrue(delegate.videoExportCalled, "Delegate video export function not called")
    }
    
    func testConfirmPhotoAsPhotoInStopMotionMode() {
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let settings = getCameraSettings()
        settings.exportStopMotionPhotoAsVideo = true
        let handler = newAssetHandlerStub()
        let viewController = newViewController(settings: settings, segments: segments, delegate: delegate, assetsHandler: handler, cameraMode: .photo)
        viewController.didTapConfirmButton()
        XCTAssertTrue(!handler.mergeAssetsCalled, "Handler merge assets function called")
        XCTAssertTrue(delegate.imageExportCalled, "Delegate image export function not called")
        XCTAssertFalse(delegate.videoExportCalled, "Delegate video export function should not be called")
    }
    
    func testConfirmVideos() {
        let segments = getVideoSegments()
        let delegate = newDelegateStub()
        let handler = newAssetHandlerStub()
        let viewController = newViewController(segments: segments, delegate: delegate, assetsHandler: handler)
        UIView.setAnimationsEnabled(false)
        viewController.didTapConfirmButton()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
        XCTAssert(handler.mergeAssetsCalled, "Handler merge assets function not called")
        XCTAssert(delegate.videoExportCalled, "Delegate video export function not called")
    }
    
    func testConfirmVideosAndPhotos() {
        let segments = getAllSegments()
        let delegate = newDelegateStub()
        let handler = newAssetHandlerStub()
        let viewController = newViewController(segments: segments, delegate: delegate, assetsHandler: handler)
        UIView.setAnimationsEnabled(false)
        viewController.didTapConfirmButton()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
        XCTAssert(handler.mergeAssetsCalled, "Handler merge assets function not called")
        XCTAssert(delegate.videoExportCalled, "Delegate video export function not called")
    }
    
    func testCloseButtonPressed() {
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let viewController = newViewController(segments: segments, delegate: delegate)
        UIView.setAnimationsEnabled(false)
        viewController.didTapCloseButton()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
        XCTAssert(delegate.closeCalled, "Delegate close function not called")
    }
    
    func testEditorWithCrossIconToClose() {
        let settings = CameraSettings()
        settings.crossIconInEditor = true
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let viewController = newViewController(settings: settings, segments: segments, delegate: delegate)
        FBSnapshotVerifyView(viewController.view)
    }

    func testEditorShowsTagButton() {
        let settings = CameraSettings()
        settings.showTagButtonInEditor = true
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let viewController = newViewController(settings: settings, segments: segments, delegate: delegate)
        FBSnapshotVerifyView(viewController.view)
    }

    func testEditorWithFiltersOpenHidesTagButton() {
        let settings = CameraSettings()
        settings.showTagButtonInEditor = true
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let viewController = newViewController(settings: settings, segments: segments, delegate: delegate)
        UIView.setAnimationsEnabled(false)
        viewController.didSelectEditionOption(.filter, cell: EditionMenuCollectionCell())
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
    }

    func testEditorWhenClosingFiltersShowsTagButton() {
        let settings = CameraSettings()
        settings.showTagButtonInEditor = true
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let viewController = newViewController(settings: settings, segments: segments, delegate: delegate)
        UIView.setAnimationsEnabled(false)
        viewController.didSelectEditionOption(.filter, cell: EditionMenuCollectionCell())
        viewController.didConfirmFilters()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
    }
}

final class EditorControllerDelegateStub: EditorControllerDelegate {

    private(set) var closeCalled = false
    private(set) var videoExportCalled = false
    private(set) var imageExportCalled = false
    private(set) var framesExportCalled = false
    
    func didFinishExportingVideo(url: URL?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool) {
        XCTAssertNotNil(url)
        videoExportCalled = true
    }
    
    func didFinishExportingImage(image: UIImage?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool) {
        XCTAssertNotNil(image)
        imageExportCalled = true
    }

    func didFinishExportingFrames(url: URL?, size: CGSize?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool) {
        XCTAssertNotNil(url)
        framesExportCalled = true
    }
    
    func dismissButtonPressed() {
        closeCalled = true
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

    func tagButtonPressed() {

    }
}
