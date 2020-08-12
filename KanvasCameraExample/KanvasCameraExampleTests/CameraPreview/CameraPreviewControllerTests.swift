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

final class CameraPreviewControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
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

    func newViewController(settings: CameraSettings = CameraSettings(), segments: [CameraSegment], delegate: CameraPreviewControllerDelegate? = nil, assetsHandler: AssetsHandlerType? = nil, cameraMode: CameraMode? = nil) -> CameraPreviewViewController {
        let handler = assetsHandler ?? AssetsHandlerStub()
        let viewController = CameraPreviewViewController(settings: settings, segments: segments, assetsHandler: handler, cameraMode: cameraMode)
        viewController.delegate = delegate ?? newDelegateStub()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return viewController
    }

    func newDelegateStub() -> CameraPreviewControllerDelegateStub {
        let stub = CameraPreviewControllerDelegateStub()
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
        viewController.confirmButtonPressed()
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
        viewController.confirmButtonPressed()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
        XCTAssert(handler.mergeAssetsCalled, "Handler merge assets function not called")
        XCTAssert(delegate.videoExportCalled, "Delegate video export function not called")
    }
    
    func testConfirmPhotoAsVideoInStopMotionMode() {
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.exportStopMotionPhotoAsVideo = true
        let handler = newAssetHandlerStub()
        let viewController = newViewController(settings: settings, segments: segments, delegate: delegate, assetsHandler: handler, cameraMode: .stopMotion)
        viewController.confirmButtonPressed()
        XCTAssertTrue(!handler.mergeAssetsCalled, "Handler merge assets function called")
        XCTAssertTrue(delegate.videoExportCalled, "Delegate video export function not called")
    }
    
    func testConfirmPhotoAsPhotoInStopMotionMode() {
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let settings = CameraSettings()
        settings.exportStopMotionPhotoAsVideo = true
        let handler = newAssetHandlerStub()
        let viewController = newViewController(settings: settings, segments: segments, delegate: delegate, assetsHandler: handler, cameraMode: .photo)
        viewController.confirmButtonPressed()
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
        viewController.confirmButtonPressed()
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
        viewController.confirmButtonPressed()
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
        viewController.closeButtonPressed()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
        XCTAssert(delegate.closeCalled, "Delegate close function not called")
    }

}

final class CameraPreviewControllerDelegateStub: CameraPreviewControllerDelegate {
    private(set) var closeCalled = false
    private(set) var videoExportCalled = false
    private(set) var imageExportCalled = false
    private(set) var framesExportCalled = false

    func didFinishExportingVideo(url: URL?) {
        XCTAssertNotNil(url)
        videoExportCalled = true
    }

    func didFinishExportingImage(image: UIImage?) {
        XCTAssertNotNil(image)
        imageExportCalled = true
    }

    func didFinishExportingFrames(url: URL?) {
        XCTAssertNotNil(url)
        framesExportCalled = true
    }

    func dismissButtonPressed() {
        closeCalled = true
    }
}

final class AssetsHandlerStub: AssetsHandlerType {
    private(set) var mergeAssetsCalled = false

    func mergeAssets(segments: [CameraSegment], completion: @escaping (URL?, MediaInfo?) -> Void) {
        mergeAssetsCalled = true
        let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4")
        let mediaInfo = MediaInfo(source: .kanvas_camera)
        completion(videoURL, mediaInfo)
    }

    func ensureAllImagesHaveVideo(segments: [CameraSegment], completion: @escaping ([CameraSegment]) -> ()) {
        let newSegments = segments.map { (segment) -> CameraSegment in
            switch segment {
            case let .image(image, _, interval, mt):
                let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4")
                return CameraSegment.image(image, videoURL, interval, mt)
            case let .video(url, mt):
                return CameraSegment.video(url, mt)
            }
        }
        completion(newSegments)
    }

}
