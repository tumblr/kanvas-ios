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
    var filterType: FilterType? = nil
    var imageOverlays: [CGImage] = []

    var exportImageCalled: Bool = false
    var exportVideoCalled: Bool = false

    required init() {

    }

    func export(image: UIImage, completion: (UIImage?, Error?) -> Void) {
        exportImageCalled = true
        completion(image, nil)
    }

    func export(video url: URL, completion: @escaping (URL?, Error?) -> Void) {
        exportVideoCalled = true
        completion(url, nil)
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
        settings.features.editorFilters = true
        settings.features.editorMedia = true
        settings.features.editorDrawing = true
        return settings
    }
    
    func getAllSegments() -> [CameraSegment] {
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }),
            let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            return [
                CameraSegment.image(image, videoURL),
                CameraSegment.video(videoURL),
                CameraSegment.image(image, videoURL),
                CameraSegment.video(videoURL)
            ]
        }
        return []
    }
    
    func getVideoSegments() -> [CameraSegment] {
        if let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            return [
                CameraSegment.video(videoURL),
                CameraSegment.video(videoURL)
            ]
        }
        return []
    }
    
    func getPhotoSegment() -> [CameraSegment] {
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }),
            let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            return [
                CameraSegment.image(image, videoURL)
            ]
        }
        return []
    }
    
    func getPhotoSegments() -> [CameraSegment] {
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }),
            let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            return [
                CameraSegment.image(image, videoURL),
                CameraSegment.image(image, videoURL)
            ]
        }
        return []
    }
    
    func newViewController(settings: CameraSettings? = nil, segments: [CameraSegment], delegate: EditorControllerDelegate? = nil, assetsHandler: AssetsHandlerType? = nil, cameraMode: CameraMode? = nil, analyticsProvider: KanvasCameraAnalyticsProvider? = nil) -> EditorViewController {
        let cameraSettings = settings ?? getCameraSettings()
        let handler = assetsHandler ?? AssetsHandlerStub()
        let analytics = analyticsProvider ?? KanvasCameraAnalyticsStub()
        let viewController = EditorViewController(settings: cameraSettings, segments: segments, assetsHandler: handler, exporterClass: MediaExporterStub.self, cameraMode: cameraMode, analyticsProvider: analytics)
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
        XCTAssert(handler.mergeAssetsCalled, "Handler merge assets function not called")
        XCTAssert(delegate.videoExportCalled, "Delegate video export function not called")
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
    
}

final class EditorControllerDelegateStub: EditorControllerDelegate {
    private(set) var closeCalled = false
    private(set) var videoExportCalled = false
    private(set) var imageExportCalled = false
    
    func didFinishExportingVideo(url: URL?, action: KanvasExportAction) {
        XCTAssertNotNil(url)
        videoExportCalled = true
    }
    
    func didFinishExportingImage(image: UIImage?, action: KanvasExportAction) {
        XCTAssertNotNil(image)
        imageExportCalled = true
    }
    
    func dismissButtonPressed() {
        closeCalled = true
    }
    
    func didDismissColorSelecterTooltip() {
        
    }
    
    func editorShouldShowColorSelecterTooltip() -> Bool {
        return false
    }
    
    func didEndStrokeSelectorAnimation() {
        
    }
    
    func editorShouldShowStrokeSelectorAnimation() -> Bool {
        return false
    }
}
