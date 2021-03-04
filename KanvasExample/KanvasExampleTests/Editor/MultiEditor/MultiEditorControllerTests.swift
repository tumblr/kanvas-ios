//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest
import FBSnapshotTestCase
@testable import Kanvas

class MultiEditorControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func getPhotoSegment() -> [CameraSegment] {
        if let imagePath = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"),
           let image = UIImage(contentsOfFile: imagePath) {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            return [
                CameraSegment.image(image, nil, nil, mediaInfo)
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

    func newDelegateStub() -> MultiEditorControllerDelegateStub {
        let stub = MultiEditorControllerDelegateStub(settings: getCameraSettings())
        return stub
    }

    func newViewController(settings: CameraSettings? = nil, frames: [MultiEditorViewController.Frame], delegate: MultiEditorComposerDelegate? = nil) -> MultiEditorViewController {
        let cameraSettings = settings ?? getCameraSettings()
        let viewController = MultiEditorViewController(settings: cameraSettings, frames: frames, delegate: delegate ?? newDelegateStub(), selected: 0)
        viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return viewController
    }

    func frames(segments: [CameraSegment]) -> [MultiEditorViewController.Frame] {
        return segments.map { segment in
            MultiEditorViewController.Frame(segment: segment, edit: nil)
        }
    }

    func testExportPhoto() {
        let segments = getPhotoSegment()
        let delegate = newDelegateStub()
        let settings = getCameraSettings()
        let inFrames = frames(segments: segments)
        settings.exportStopMotionPhotoAsVideo = false
        let viewController = newViewController(settings: settings, frames: inFrames, delegate: delegate)
        let expectation = XCTestExpectation(description: "Media Exported")
        delegate.exportingCompletion = { results in
            XCTAssertEqual(results.count, segments.count, "The exported media should equal the number of segments")
            expectation.fulfill()
        }
        _ = viewController.shouldExport()
        wait(for: [expectation], timeout: 2)
    }

    func testExportPhotoVideo() {
        let segments = getPhotoSegment() + getVideoSegments()
        let delegate = newDelegateStub()
        let settings = getCameraSettings()
        let inFrames = frames(segments: segments)
        settings.exportStopMotionPhotoAsVideo = false
        let viewController = newViewController(settings: settings, frames: inFrames, delegate: delegate)
        let expectation = XCTestExpectation(description: "Media Exported")
        delegate.exportingCompletion = { results in
            XCTAssertEqual(results.count, segments.count, "The exported media should equal the number of segments")
            expectation.fulfill()
        }
        _ = viewController.shouldExport()
        wait(for: [expectation], timeout: 2)
    }

    func testShift() {
        let segments = getPhotoSegment() + getPhotoSegment() + getPhotoSegment()
        let inFrames = frames(segments: segments)
        let vc = newViewController(frames: inFrames)
        let frameMovedAhead = vc.shift(index: 2, moves: [(1,0)], edits: inFrames)
        XCTAssertEqual(frameMovedAhead, 2, "Selection shouldn't change")
        let frameMovedBehind = vc.shift(index: 0, moves: [(1,2)], edits: inFrames)
        XCTAssertEqual(frameMovedBehind, 0, "Selection shouldn't change")
        let frameMovedInFront = vc.shift(index: 1, moves: [(0,2)], edits: inFrames)
        XCTAssertEqual(frameMovedInFront, 1, "Selection shouldn't change")
        let frameMovedInBack = vc.shift(index: 1, moves: [(0,2)], edits: inFrames)
        XCTAssertEqual(frameMovedInBack, 1, "Selection shouldn't change")
    }

    func testDeletedIndex() {
        let segments = getPhotoSegment() + getPhotoSegment() + getPhotoSegment()
        let inFrames = frames(segments: segments)
        let vc = newViewController(frames: inFrames)

        let frameMovedAhead = vc.shift(index: 2, moves: [(1,0)], edits: inFrames)
        XCTAssertEqual(frameMovedAhead, 2, "Selection shouldn't change")
        let frameMovedBehind = vc.shift(index: 0, moves: [(1,2)], edits: inFrames)
        XCTAssertEqual(frameMovedBehind, 0, "Selection shouldn't change")
        let frameMovedInFront = vc.shift(index: 1, moves: [(0,2)], edits: inFrames)
        XCTAssertEqual(frameMovedInFront, 0, "Selection should be moved back")
        let frameMovedInBack = vc.shift(index: 1, moves: [(2,0)], edits: inFrames)
        XCTAssertEqual(frameMovedInBack, 2, "Selection should be moved forward")
    }

    func testRemovedIndex() {
        let segments = getPhotoSegment() + getPhotoSegment() + getPhotoSegment()
        var inFrames = frames(segments: segments)
        let vc = newViewController(frames: inFrames)

        inFrames.removeLast(2)
        let deletedLast = vc.newIndex(indices: [2], selected: 2, edits: inFrames)
        XCTAssertEqual(deletedLast, 1, "Selection should move back")
        inFrames = inFrames + frames(segments: getPhotoSegment())
        inFrames.removeFirst(1)
        let deletedFirst = vc.newIndex(indices: [0], selected: 0, edits: inFrames)
        XCTAssertEqual(deletedFirst, 0, "Selection should not move")
        inFrames = frames(segments: getPhotoSegment()) + inFrames

        inFrames.removeFirst(1)
        let deletedInFront = vc.newIndex(indices: [0], selected: 1, edits: inFrames)
        XCTAssertEqual(deletedInFront, 0, "Selection should be moved back")
        inFrames = frames(segments: getPhotoSegment()) + inFrames

        inFrames.removeLast(2)
        let deletedInBack = vc.newIndex(indices: [1], selected: 0, edits: inFrames)
        XCTAssertEqual(deletedInBack, 0, "Selection shouldn't change")
    }
}

final class MultiEditorControllerDelegateStub: MultiEditorComposerDelegate {

    let settings: CameraSettings
    let assetsHandler: AssetsHandlerType
    let exporterClass: MediaExporting.Type
    let gifEncoderClass: GIFEncoder.Type

    init(settings: CameraSettings, assetsHandler: AssetsHandlerType? = nil, exporterClass: MediaExporting.Type? = nil, gifEncoderClass: GIFEncoder.Type? = nil) {
        self.settings = settings
        self.assetsHandler = assetsHandler ?? AssetsHandlerStub()
        self.exporterClass = exporterClass ?? MediaExporterStub.self
        self.gifEncoderClass = gifEncoderClass ?? GIFEncoderStub.self
    }

    var exportingCompletion: (([Result<EditorViewController.ExportResult, Error>]) -> Void)?

    func didFinishExporting(media: [Result<EditorViewController.ExportResult, Error>]) {
        exportingCompletion?(media)
    }

    func addButtonWasPressed() {

    }

    func editor(segment: CameraSegment, edit: EditorViewController.Edit?) -> EditorViewController {
        return EditorViewController(settings: settings,
                                    segments: [segment],
                                    assetsHandler: assetsHandler,
                                    exporterClass: exporterClass,
                                    gifEncoderClass: gifEncoderClass,
                                    cameraMode: nil,
                                    stickerProvider: nil,
                                    analyticsProvider: nil,
                                    quickBlogSelectorCoordinator: nil,
                                    edit: edit,
                                    tagCollection: nil)
    }

    func didFinishExportingVideo(url: URL?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {

    }

    func didFinishExportingImage(image: UIImage?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {

    }

    func didFinishExportingFrames(url: URL?, size: CGSize?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {

    }

    func dismissButtonPressed() {

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

    func getQuickPostButton() -> UIView {
        return UIView()
    }

    func getBlogSwitcher() -> UIView {
        return UIView()
    }


    
}
