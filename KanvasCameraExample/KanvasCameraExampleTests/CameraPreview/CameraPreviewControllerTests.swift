//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest
import FBSnapshotTestCase

final class CameraPreviewControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
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

    func newViewController(segments: [CameraSegment], delegate: CameraPreviewControllerDelegate? = nil, assetsHandler: AssetsHandlerType? = nil) -> CameraPreviewViewController {
        let handler = assetsHandler ?? AssetsHandlerStub()
        let viewController = CameraPreviewViewController(settings: CameraSettings(), segments: segments, assetsHandler: handler)
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

    func didFinishExportingVideo(url: URL?) {
        XCTAssertNotNil(url)
        videoExportCalled = true
    }

    func didFinishExportingImage(image: UIImage?) {
        XCTAssertNotNil(image)
        imageExportCalled = true
    }

    func dismissButtonPressed() {
        closeCalled = true
    }
}

final class AssetsHandlerStub: AssetsHandlerType {
    private(set) var mergeAssetsCalled = false

    func mergeAssets(segments: [CameraSegment], completion: @escaping (URL?) -> Void) {
        mergeAssetsCalled = true
        let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4")
        completion(videoURL)
    }


}
