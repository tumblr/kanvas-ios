//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for camera editor controller methods

public protocol EditorControllerDelegate: class {
    /// callback when finished exporting video clips.
    func didFinishExportingVideo(url: URL?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool)

    /// callback when finished exporting image
    func didFinishExportingImage(image: UIImage?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool)

    /// callback when finished exporting frames
    func didFinishExportingFrames(url: URL?, size: CGSize?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool)
    
    /// callback when dismissing controller without exporting
    func dismissButtonPressed()
    
    /// Called after the color selector tooltip is dismissed
    func didDismissColorSelectorTooltip()
    
    /// Called to ask if color selector tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func editorShouldShowColorSelectorTooltip() -> Bool
    
    /// Called after the stroke animation has ended
    func didEndStrokeSelectorAnimation()
    
    /// Called to ask if stroke selector animation should be shown
    ///
    /// - Returns: Bool for animation
    func editorShouldShowStrokeSelectorAnimation() -> Bool

    /// Called when the tag button is pressed
    func tagButtonPressed()
    
    /// Called when the Post Button is pressed to indicate whether export should occur
    /// The return value indicates whether the export should be run
    /// This is partly temporary, I think the export functionality should be passed into this controller to decouple things
    func shouldExport() -> Bool
}

extension EditorControllerDelegate {
    public func shouldExport() -> Bool {
        return true
    }
}

private struct Constants {
    static let pageName: String = "KanvasEditor"
}

/// A view controller to edit the segments
public final class EditorViewController: UIViewController, MediaPlayerController, EditorViewDelegate, KanvasEditorMenuControllerDelegate, EditorFilterControllerDelegate, DrawingControllerDelegate, EditorTextControllerDelegate, MediaDrawerControllerDelegate, GifMakerHandlerDelegate, MediaPlayerDelegate {

    var editorView: EditorView
    
    private lazy var collectionController: KanvasEditorMenuController = {
        let exportAsGif = shouldEnableGIFButton() ? shouldExportAsGIFByDefault() : nil
        let controller: KanvasEditorMenuController
        
        if settings.editToolsRedesign {
            controller = StyleMenuCollectionController(settings: self.settings, shouldExportMediaAsGIF: exportAsGif)
        }
        else {
            controller = EditionMenuCollectionController(settings: self.settings, shouldExportMediaAsGIF: exportAsGif)
        }
        
        controller.delegate = self
        return controller
    }()
    
    private lazy var filterController: EditorFilterController = {
        let controller = EditorFilterController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    
    private lazy var textController: EditorTextController = {
        let textViewSettings = EditorTextView.Settings(fontSelectorUsesFont: settings.fontSelectorUsesFont)
        let settings = EditorTextController.Settings(textViewSettings: textViewSettings)
        let controller = EditorTextController(settings: settings)
        controller.delegate = self
        return controller
    }()
    
    private lazy var drawingController: DrawingController = {
        let controller = DrawingController(analyticsProvider: analyticsProvider)
        controller.delegate = self
        return controller
    }()
    
    private lazy var mediaDrawerController: MediaDrawerController = {
        let controller = MediaDrawerController(stickerProvider: self.stickerProvider)
        controller.delegate = self
        return controller
    }()
    
    private lazy var gifMakerController: GifMakerController = {
        let controller = GifMakerController()
        controller.delegate = gifMakerHandler
        return controller
    }()

    private lazy var gifMakerHandler: GifMakerHandler = {
        let handler = GifMakerHandler(analyticsProvider: analyticsProvider)
        handler.delegate = self
        return handler
    }()

    private lazy var loadingView: LoadingIndicatorView = LoadingIndicatorView()

    private let quickBlogSelectorCoordinater: KanvasQuickBlogSelectorCoordinating?
    private let tagCollection: UIView?
    private let analyticsProvider: KanvasCameraAnalyticsProvider?
    private let settings: CameraSettings
    private var originalSegments: [CameraSegment]
    private var segments: [CameraSegment] {
        return gifMakerHandler.segments ?? originalSegments
    }
    private let assetsHandler: AssetsHandlerType
    private let exporterClass: MediaExporting.Type
    private var gifEncoderClass: GIFEncoder.Type
    private let stickerProvider: StickerProvider?
    private let cameraMode: CameraMode?
    private var openedMenu: EditionOption?
    private var selectedCell: KanvasEditorMenuCollectionCell?

    var shouldExportSound: Bool = true
    private let metalContext = MetalContext.createContext()

    private var shouldExportMediaAsGIF: Bool {
        get {
            return collectionController.shouldExportMediaAsGIF
        }
        set {
            collectionController.shouldExportMediaAsGIF = newValue
        }
    }

    private let player: MediaPlayer
    private var filterType: FilterType? {
        didSet {
            player.filterType = filterType
        }
    }
    
    private var mediaChanged: Bool {
        let hasStickerOrText = !editorView.movableViewCanvas.isEmpty
        let filterApplied = filterType?.filterApplied ?? false
        let hasDrawings = !drawingController.isEmpty
        let gifMakerOpened = shouldExportMediaAsGIF
        return hasStickerOrText || filterApplied || hasDrawings || gifMakerOpened
    }

    private var editingNewText: Bool = true

    public weak var delegate: EditorControllerDelegate?
    
    private var exportCompletion: ((Result<(UIImage?, URL?, MediaInfo), Error>) -> Void)?

    private static func editor(delegate: EditorViewDelegate?,
                               settings: CameraSettings,
                               canvas: MovableViewCanvas?,
                               showsMuteButton: Bool,
                               quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?,
                               drawingView: IgnoreTouchesView?,
                               tagCollection: UIView?,
                               metalContext: MetalContext?) -> EditorView {
        var mainActionMode: EditorView.MainActionMode = .confirm
        if settings.features.editorPostOptions {
            mainActionMode = .postOptions
        }
        else if settings.features.editorPosting {
            mainActionMode = .post
        } else if settings.features.multipleExports {
            mainActionMode = .publish
        }

        let editorView: EditorView = EditorView(delegate: delegate,
                                    mainActionMode: mainActionMode,
                                    showSaveButton: settings.features.editorSaving,
                                    showMuteButton: showsMuteButton,
                                    showCrossIcon: settings.crossIconInEditor,
                                    showCogIcon: settings.showCogIconInEditor,
                                    showTagButton: settings.showTagButtonInEditor,
                                    showTagCollection: settings.showTagCollectionInEditor,
                                    showQuickPostButton: settings.showQuickPostButtonInEditor,
                                    enableQuickPostLongPress: settings.enableQuickPostLongPress,
                                    showBlogSwitcher: settings.showBlogSwitcherInEditor,
                                    editToolsRedesign: settings.editToolsRedesign,
                                    quickBlogSelectorCoordinator: quickBlogSelectorCoordinator,
                                    tagCollection: tagCollection,
                                    metalContext: metalContext,
                                    movableViewCanvas: canvas,
                                    drawingCanvas: drawingView)
        return editorView
    }

    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    public static func createEditor(for image: UIImage,
                                    settings: CameraSettings,
                                    stickerProvider: StickerProvider,
                                    analyticsProvider: KanvasCameraAnalyticsProvider) -> EditorViewController {
        EditorViewController(settings: settings,
                             segments: [.image(image, nil, nil, MediaInfo(source: .media_library))],
                             assetsHandler: CameraSegmentHandler(),
                             exporterClass: MediaExporter.self,
                             gifEncoderClass: GIFEncoderImageIO.self,
                             cameraMode: nil,
                             stickerProvider: stickerProvider,
                             analyticsProvider: analyticsProvider,
                             quickBlogSelectorCoordinator: nil,
                             tagCollection: nil)
    }
    
    public static func createEditor(for videoURL: URL, settings: CameraSettings, stickerProvider: StickerProvider) -> EditorViewController {
        EditorViewController(settings: settings,
                             segments: [.video(videoURL, MediaInfo(source: .media_library))],
                             assetsHandler: CameraSegmentHandler(),
                             exporterClass: MediaExporter.self,
                             gifEncoderClass: GIFEncoderImageIO.self,
                             cameraMode: nil,
                             stickerProvider: stickerProvider,
                             analyticsProvider: nil,
                             quickBlogSelectorCoordinator: nil,
                             tagCollection: nil)
    }

    public static func createEditor(forGIF url: URL,
                              info: MediaInfo,
                              settings: CameraSettings,
                              stickerProvider: StickerProvider,
                              analyticsProvider: KanvasCameraAnalyticsProvider,
                              completion: @escaping (EditorViewController) -> Void) {
        GIFDecoderFactory.main().decode(image: url) { frames in
            let segments = CameraSegment.from(frames: frames, info: info)
            let editor = EditorViewController(settings: settings,
                                              segments: segments,
                                              stickerProvider: stickerProvider,
                                              analyticsProvider: analyticsProvider)
            completion(editor)
        }
    }

    convenience init(settings: CameraSettings,
                     segments: [CameraSegment],
                     stickerProvider: StickerProvider,
                     analyticsProvider: KanvasCameraAnalyticsProvider) {
        self.init(settings: settings,
                  segments: segments,
                  assetsHandler: CameraSegmentHandler(),
                  exporterClass: MediaExporter.self,
                  gifEncoderClass: GIFEncoderImageIO.self,
                  cameraMode: nil,
                  stickerProvider: stickerProvider,
                  analyticsProvider: analyticsProvider,
                  quickBlogSelectorCoordinator: nil,
                  tagCollection: nil)
    }
    
    /// The designated initializer for the editor controller
    ///
    /// - Parameters:
    ///   - settings: The CameraSettings instance for export optioins
    ///   - segments: The segments to playback
    ///   - assetsHandler: The assets handler type, for testing.
    ///   - cameraMode: The camera mode that the preview was coming from, if any
    ///   - stickerProvider: Class that will provide the stickers in the editor.
    ///   - analyticsProvider: A class conforming to KanvasCameraAnalyticsProvider
    init(settings: CameraSettings,
         segments: [CameraSegment],
         assetsHandler: AssetsHandlerType,
         exporterClass: MediaExporting.Type,
         gifEncoderClass: GIFEncoder.Type,
         cameraMode: CameraMode?,
         stickerProvider: StickerProvider?,
         analyticsProvider: KanvasCameraAnalyticsProvider?,
         quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?,
         views: [View]? = nil,
         canvas: MovableViewCanvas? = nil,
         drawingView: IgnoreTouchesView? = nil,
         tagCollection: UIView?) {
        self.settings = settings
        self.originalSegments = segments
        self.assetsHandler = assetsHandler
        self.cameraMode = cameraMode
        self.analyticsProvider = analyticsProvider
        self.exporterClass = exporterClass
        self.gifEncoderClass = gifEncoderClass
        self.stickerProvider = stickerProvider
        self.quickBlogSelectorCoordinater = quickBlogSelectorCoordinator
        self.tagCollection = tagCollection

        self.player = MediaPlayer(renderer: Renderer(settings: settings, metalContext: MetalContext.createContext()))
        let muteButtonShown = settings.features.muteButton && segments.first?.image == nil
        self.editorView = EditorViewController.editor(delegate: nil,
                                                      settings: settings,
                                                      canvas: canvas,
                                                      showsMuteButton: muteButtonShown,
                                                      quickBlogSelectorCoordinator: quickBlogSelectorCoordinator,
                                                      drawingView: drawingView,
                                                      tagCollection: tagCollection,
                                                      metalContext: metalContext)
        super.init(nibName: .none, bundle: .none)
        self.editorView.delegate = self

        editorView.delegate = self
        player.playerView = editorView.playerView
        
        self.player.delegate = self

//        views?.forEach { view in
//            let type = view.viewType
//
//            let info = view.viewInfo
//
//            let innerElement: MovableViewInnerElement
//            if type == "TEXT" {
//                let textView = StylableTextView()
//                textView.text = info.addedViewTextInfo.text
////                textView.textColor
////                textView.highlightColor =
////                textView.textAlignment = info.addedViewTextInfo.text
//                textView.textAlignment = info.addedViewTextInfo.textAlignment.nsAlignment
//                innerElement = textView
//            } else {
//                innerElement = StylableImageView(id: "", image: nil)
//            }
//
//            let location = CGPoint(x: CGFloat(info.translationX), y: CGFloat(info.translationY))
//
//            let transformations = ViewTransformations(position: location, scale: CGFloat(info.scale), rotation: CGFloat(info.rotation))
//
//            editorView.movableViewCanvas.addView(view: innerElement, transformations: transformations, location: location, size: info.size)
//        }

        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func appDidBecomeActive() {
        player.resume()
    }

    @objc private func appWillResignActive() {
        player.pause()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        startPlayerFromSegments()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        editorView.add(into: view)
        drawingController.drawingLayer = editorView.drawingCanvas.layer
        
        load(childViewController: collectionController, into: editorView.collectionContainer)
        load(childViewController: filterController, into: editorView.filterMenuContainer)
        load(childViewController: textController, into: editorView.textMenuContainer)
        load(childViewController: drawingController, into: editorView.drawingMenuContainer)
        load(childViewController: gifMakerController, into: editorView.gifMakerMenuContainer)

        if shouldOpenGIFMakerOnLoad() {
            openGIFMaker(animated: false)
        }
        else if shouldConvertMediaToGIFOnLoad() {
            loadMediaAsGIF(permanent: true)
        }
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: - Views
    
    /// Sets up the color carousels of both drawing and text tools
    private func addCarouselDefaultColors(_ image: UIImage) {
        let dominantColors = image.getDominantColors(count: 3)
        drawingController.addColorsForCarousel(colors: dominantColors)
        
        if let mostDominantColor = dominantColors.first {
            textController.addColorsForCarousel(colors: [mostDominantColor, .white, .black])
        }
    }

    // MARK: - Media Player

    /// Loads the media into the player and starts it.
    private func startPlayerFromSegments() {
        let media: [MediaPlayerContent] = segments.compactMap { segment in
            switch segment {
            case .image(let image, _, _, _):
                return .image(image, segment.timeInterval)
            case .video(let url, _):
                return .video(url)
            }
        }
        player.play(media: media)
    }
    
    // MARK: - Loading Indicator

    /// Shows the loading indicator on this view
    func showLoading() {
        loadingView.add(into: view)
        loadingView.startLoading()
    }
    
    /// Removes the loading indicator on this view
    func hideLoading() {
        loadingView.removeFromSuperview()
        loadingView.stopLoading()
    }

    // MARK: - GIF Maker Helpers

    private func openGIFMaker(animated: Bool) {
        guard let cell = collectionController.getCell(for: .gif) else {
            assertionFailure("Failed to open GIF Maker")
            return
        }
        openGIFMaker(cell: cell, animated: animated, permanent: true)
    }

    private func openGIFMaker(cell: KanvasEditorMenuCollectionCell, animated: Bool, permanent: Bool) {
        let editionOption = EditionOption.gif
        onBeforeShowingEditionMenu(editionOption, cell: cell)
        showMainUI(false)
        gifMakerController.showView(true)
        loadMediaAsGIF(permanent: permanent)
        if animated {
            self.editorView.animateEditionOption(cell: cell, finalLocation: self.gifMakerController.confirmButtonLocation) {_ in
                self.gifMakerController.showConfirmButton(true)
            }
        }
        else {
            gifMakerController.showConfirmButton(true)
        }
        analyticsProvider?.logEditorGIFOpen()
    }

    private func revertGIF() {
        if settings.animateEditorControls {
            editorView.animateReturnOfEditionOption(cell: selectedCell)
        }
        gifMakerController.showView(false)
        gifMakerController.showConfirmButton(false)
        gifMakerHandler.revert { reverted in
            if reverted {
                self.player.stop()
                self.startPlayerFromSegments()
            }
        }
        shouldExportMediaAsGIF = shouldForceExportAsAGIF()
        showMainUI(true)
        analyticsProvider?.logEditorGIFRevert()
        onAfterConfirmingEditionMenu()
    }

    private func loadMediaAsGIF(permanent: Bool) {
        gifMakerHandler.load(segments: segments,
                             initialSettings: .init(rate: initialGIFPlaybackRate(),
                                                    playbackMode: initialGIFPlaybackMode(),
                                                    startTime: initialGIFTrim().lowerBound,
                                                    endTime: initialGIFTrim().upperBound),
                             permanent: permanent,
                             showLoading: self.showLoading,
                             hideLoading: self.hideLoading,
                             completion: { framesUpdated in
                                if framesUpdated {
                                    self.player.stop()
                                    self.startPlayerFromSegments()
                                    if permanent, let newSegments = self.gifMakerHandler.segments {
                                        self.originalSegments = newSegments
                                    }
                                }
                                self.gifMakerController.configure(settings: self.gifMakerHandler.settings, animated: false)
                                self.configureMediaPlayer(settings: self.gifMakerHandler.settings)
                             })
    }

    private func shouldEnableGIFButton() -> Bool {
        guard settings.features.gifs else {
            return false
        }

        // More than one segment, or one video-only segment, enable it.
        if segments.count > 1 || segments.first?.image == nil {
            return true
        }

        // A single segment that has both an image and a video (live photo), enabled it.
        if segments.count == 1,
            let firstSegment = segments.first,
            firstSegment.image != nil,
            firstSegment.videoURL != nil {
            return true
        }

        return false
    }

    private func shouldForceExportAsAGIF() -> Bool {
        guard settings.features.gifs else {
            return false
        }

        // Media captured from the GIF mode should always export as a GIF
        if cameraMode?.group == .gif {
            return true
        }

        // Media from the picker or directly loaded, that has only images, are GIFs.
        if (cameraMode == nil || cameraMode == .some(.normal)) && segments.count > 1 && assetsHandler.containsOnlyImages(segments: segments) {
            return true
        }

        return false
    }

    private func shouldExportAsGIFByDefault() -> Bool {
        guard settings.features.gifs else {
            return false
        }

        if shouldForceExportAsAGIF() {
            return true
        }

        // Media captured with only images (but at least two) should export as a GIF by default
        if segments.count > 1 && assetsHandler.containsOnlyImages(segments: segments) {
            return true
        }

        return false
    }

    private func shouldOpenGIFMakerOnLoad() -> Bool {
        guard
            settings.features.gifs,
            settings.features.editorGIFMaker,
            shouldEnableGIFButton()
        else {
            return false
        }

        return settings.editorShouldStartGIFMaker(mode: cameraMode)
    }

    private func shouldConvertMediaToGIFOnLoad() -> Bool {
        shouldExportAsGIFByDefault()
    }

    private func initialGIFPlaybackMode() -> PlaybackOption {
        if cameraMode?.group == .gif {
            return .rebound
        }
        return .loop
    }

    private func initialGIFPlaybackRate() -> Float {
        return 1.0
    }

    private func initialGIFTrim() -> ClosedRange<TimeInterval> {
        return 0...3
    }
    
    // MARK: - EditorViewDelegate
    
    func didTapSaveButton() {
        startExporting(action: .save)
        analyticsProvider?.logSaveFromDashboard()
    }

    func didTapMuteButton(enabled: Bool) {
        player.isMuted = enabled
        shouldExportSound = !enabled
    }

    func didTapPostButton() {
        if delegate?.shouldExport() ?? true {
            startExporting(action: .post)
        }
        analyticsProvider?.logPostFromDashboard()
    }

    func didTapConfirmButton() {
        startExporting(action: .confirm)
        analyticsProvider?.logOpenComposeFromDashboard()
    }

    func didTapPostOptionsButton() {
        startExporting(action: .postOptions)
        analyticsProvider?.logAdvancedOptionsOpen(page: Constants.pageName)
    }
    
    func didTapText(options: TextOptions, transformations: ViewTransformations) {
        let cell = collectionController.getCell(for: .text)
        onBeforeShowingEditionMenu(.text, cell: cell)
        showMainUI(false)
        textController.showView(true, options: options, transformations: transformations)
        if settings.animateEditorControls {
            editorView.animateEditionOption(cell: cell, finalLocation: textController.confirmButtonLocation, completion: { _ in
                self.textController.showConfirmButton(true)
            })
        } else {
            self.textController.showConfirmButton(true)
        }
        analyticsProvider?.logEditorTextEdit()
        editingNewText = false
    }

    func didMoveText() {
        analyticsProvider?.logEditorTextMove()
    }

    func didRemoveText() {
        analyticsProvider?.logEditorTextRemove()
    }
    
    func didMoveImage(_ imageView: StylableImageView) {
        analyticsProvider?.logEditorStickerMove(stickerId: imageView.id)
    }
    
    func didRemoveImage(_ imageView: StylableImageView) {
        analyticsProvider?.logEditorStickerRemove(stickerId: imageView.id)
    }

    func didTapTagButton() {
        delegate?.tagButtonPressed()
        analyticsProvider?.logEditorTagTapped()
    }
    
    func didBeginTouchesOnText() {
        showNavigationContainer(false)
    }
    
    func didEndTouchesOnText() {
        showNavigationContainer(true)
    }

    func didRenderRectChange(rect: CGRect) {
        drawingController.didRenderRectChange(rect: rect)
    }

    func didTapCloseButton() {
        player.stop()
        delegate?.dismissButtonPressed()
    }
    
    func restartPlayback() {
        player.stop()
        startPlayerFromSegments()
    }
    
    func stopPlayback() {
        player.stop()
    }
    
    // MARK: - Media Exporting

    private func startExporting(action: KanvasExportAction) {
        player.stop()
        showLoading()
        if segments.count == 1, let firstSegment = segments.first, case CameraSegment.image(let image, _, _, _) = firstSegment {
            // If the camera mode is .stopMotion, .normal or .stitch (.video) and the `exportStopMotionPhotoAsVideo` is true,
            // then single photos from that mode should still export as video.
            if let cameraMode = cameraMode, cameraMode.group == .video && settings.exportStopMotionPhotoAsVideo, let videoURL = firstSegment.videoURL {
                createFinalVideo(videoURL: videoURL, mediaInfo: firstSegment.mediaInfo, exportAction: action)
            }
            else {
                createFinalImage(image: image, mediaInfo: firstSegment.mediaInfo, exportAction: action)
            }
        }
        else if shouldExportMediaAsGIF {
            if segments.count == 1, let segment = segments.first, let url = segment.videoURL {
                self.createFinalGIF(videoURL: url, framesPerSecond: KanvasCameraTimes.gifPreferredFramesPerSecond, mediaInfo: segment.mediaInfo, exportAction: action)
            }
            else if assetsHandler.containsOnlyImages(segments: segments) {
                self.createFinalGIF(segments: segments, mediaInfo: segments.first?.mediaInfo ?? MediaInfo(source: .kanvas_camera), exportAction: action)
            }
            else {
                // Segments are not all frames, so we need to generate a full video first, and then convert that to a GIF.
                // It might be nice in the future to create a GIF directly from segments.
                assetsHandler.mergeAssets(segments: segments, withAudio: true) { [weak self] url, mediaInfo in
                    guard let self = self else {
                        return
                    }
                    guard let url = url, let mediaInfo = mediaInfo else {
                        self.hideLoading()
                        self.handleExportError()
                        return
                    }
                    let fps = Int(CMTime(seconds: 1.0, preferredTimescale: KanvasCameraTimes.stopMotionFrameTimescale).seconds / KanvasCameraTimes.onlyImagesFrameTime.seconds)
                    self.createFinalGIF(videoURL: url, framesPerSecond: fps, mediaInfo: mediaInfo, exportAction: action)
                }
            }
        }
        else {
            assetsHandler.mergeAssets(segments: segments, withAudio: shouldExportSound) { [weak self] url, mediaInfo in
                guard let url = url else {
                    self?.hideLoading()
                    self?.handleExportError()
                    return
                }
                self?.createFinalVideo(videoURL: url, mediaInfo: mediaInfo ?? MediaInfo(source: .media_library), exportAction: action)
            }
        }
    }

    public func export(_ completion: @escaping (Result<(UIImage?, URL?, MediaInfo), Error>) -> Void) {
        exportCompletion = completion
        startExporting(action: .post)
    }

    private func createFinalGIF(segments: [CameraSegment], mediaInfo: MediaInfo, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init(settings: settings)
        exporter.filterType = filterType ?? .passthrough
        exporter.imageOverlays = imageOverlays()
        let segments = gifMakerHandler.trimmedSegments(segments)
        let frames = segments.compactMap { $0.mediaFrame(defaultTimeInterval: getDefaultTimeIntervalForImageSegments()) }
        exporter.export(frames: frames) { orderedFrames in
            let playbackFrames = self.gifMakerHandler.framesForPlayback(orderedFrames)
            self.gifEncoderClass.init().encode(frames: playbackFrames, loopCount: 0) { gifURL in
                var size: CGSize? = nil
                if let gifURL = gifURL {
                    size = GIFDecoderFactory.main().size(of: gifURL)
                }
                self.exportCompletion?(.success((nil, gifURL, mediaInfo)))
                self.delegate?.didFinishExportingFrames(url: gifURL, size: size, info: mediaInfo, action: exportAction, mediaChanged: self.mediaChanged)
                performUIUpdate {
                    self.hideLoading()
                }
            }
        }
    }

    private func createFinalGIF(videoURL: URL, framesPerSecond: Int, mediaInfo: MediaInfo, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init(settings: settings)
        exporter.filterType = filterType ?? .passthrough
        exporter.imageOverlays = imageOverlays()
        exporter.export(video: videoURL, mediaInfo: mediaInfo) { (exportedVideoURL, _) in
            guard let exportedVideoURL = exportedVideoURL else {
                performUIUpdate {
                    self.hideLoading()
                    self.handleExportError()
                }
                return
            }
            self.gifEncoderClass.init().encode(video: exportedVideoURL, loopCount: 0, framesPerSecond: framesPerSecond) { [weak self] gifURL in
                guard let self = self else { return }
                guard let gifURL = gifURL else {
                    performUIUpdate {
                        self.hideLoading()
                        self.handleExportError()
                    }
                    return
                }
                let size = GIFDecoderFactory.main().size(of: gifURL)
                self.exportCompletion?(.success((nil, gifURL, mediaInfo)))
                self.delegate?.didFinishExportingFrames(url: gifURL, size: size, info: mediaInfo, action: exportAction, mediaChanged: self.mediaChanged)
                performUIUpdate {
                    self.hideLoading()
                }
            }
        }
    }

    private func createFinalVideo(videoURL: URL, mediaInfo: MediaInfo, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init(settings: settings)
        exporter.imageOverlays = imageOverlays()
        let firstImage = UIImage(cgImage: exporter.imageOverlays.first!)
        exporter.filterType = filterType ?? .passthrough
        exporter.export(video: videoURL, mediaInfo: mediaInfo) { [weak self] (exportedVideoURL, _) in
            guard let self = self else { return }
            guard let url = exportedVideoURL else {
                if self.parent != nil {
                    performUIUpdate {
                        self.hideLoading()
                        self.handleExportError()
                        return
                    }
                }
                return
            }
            performUIUpdate {
                if self.parent != nil {
                    self.hideLoading()
                }
            }
            self.exportCompletion?(.success((nil, url, mediaInfo)))
            self.delegate?.didFinishExportingVideo(url: url, info: mediaInfo, action: exportAction, mediaChanged: self.mediaChanged)
        }
    }

    private func createFinalImage(image: UIImage, mediaInfo: MediaInfo, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init(settings: settings)
        exporter.filterType = filterType ?? .passthrough
        exporter.imageOverlays = imageOverlays()
        exporter.dimensions = UIScreen.main.bounds.size
        exporter.export(image: image, time: player.lastStillFilterTime) { (exportedImage, _) in
            performUIUpdate {
                guard Device.isRunningInSimulator == false else {
                    self.delegate?.didFinishExportingImage(image: UIImage(), info: mediaInfo, action: exportAction, mediaChanged: self.mediaChanged)
                    self.hideLoading()
                    return
                }
                guard let unwrappedImage = exportedImage else {
                    self.hideLoading()
                    self.handleExportError()
                    return
                }
                self.exportCompletion?(.success((unwrappedImage, nil, mediaInfo)))
                self.delegate?.didFinishExportingImage(image: unwrappedImage, info: mediaInfo, action: exportAction, mediaChanged: self.mediaChanged)
                self.hideLoading()
            }
        }
    }

    private func imageOverlays() -> [CGImage] {
        var imageOverlays: [CGImage] = []
        if let drawingLayer = drawingController.drawingLayer, let drawingOverlayImage = drawingLayer.cgImage() {
            imageOverlays.append(drawingOverlayImage)
        }
        
        if let movableViewsOverlayImage = editorView.movableViewCanvas.layer.cgImage() {
            imageOverlays.append(movableViewsOverlayImage)
        }
        return imageOverlays
    }

    private func handleExportError() {
        let alertController = UIAlertController(title: nil,
                                                message: NSLocalizedString("SomethingGoofedTitle", comment: "Alert controller message"),
                                                preferredStyle: .alert)
        let tryAgainButton = UIAlertAction(title: NSLocalizedString("Try again", comment: "Try creating final content again"), style: .default) { _ in
            alertController.dismiss(animated: true, completion: .none)
        }
        alertController.addAction(tryAgainButton)
        self.present(alertController, animated: true, completion: .none)
    }
    
    private func confirmEditionMenu() {
        guard let editionOption = openedMenu else { return }
        
        switch editionOption {
        case .gif:
            if settings.features.editorGIFMaker {
                shouldExportMediaAsGIF = gifMakerHandler.shouldExport
                if settings.animateEditorControls {
                    editorView.animateReturnOfEditionOption(cell: selectedCell)
                } else {
                    selectedCell?.alpha = 1
                }
                gifMakerController.showView(false)
                gifMakerController.showConfirmButton(false)
                showMainUI(true)
                analyticsProvider?.logEditorGIFConfirm(
                    duration: gifMakerHandler.trimmedDuration,
                    playbackMode: KanvasGIFPlaybackMode(from: gifMakerHandler.settings.playbackMode),
                    speed: gifMakerHandler.settings.rate
                )
            }
        case .filter:
            filterController.showView(false)
            showMainUI(true)
        case .text:
            if settings.animateEditorControls {
                editorView.animateReturnOfEditionOption(cell: selectedCell)
            } else {
                selectedCell?.alpha = 1
            }
            textController.showView(false)
            textController.showConfirmButton(false)
            showMainUI(true)
        case .drawing:
            if settings.animateEditorControls {
                editorView.animateReturnOfEditionOption(cell: selectedCell)
            } else {
                selectedCell?.alpha = 1
            }
            drawingController.showView(false)
            drawingController.showConfirmButton(false)
            showMainUI(true)
        case .media:
            analyticsProvider?.logEditorMediaDrawerClosed()
        }
        
        onAfterConfirmingEditionMenu()
    }
    
    /// Called to reset the editor state after confirming an edition menu
    private func onAfterConfirmingEditionMenu() {
        openedMenu = nil
        selectedCell = nil
    }
    
    // MARK: - KanvasEditionMenuControllerDelegate

    func didSelectEditionOption(_ editionOption: EditionOption, cell: KanvasEditorMenuCollectionCell) {
        switch editionOption {
        case .gif:
            if settings.features.editorGIFMaker {
                openGIFMaker(cell: cell, animated: true, permanent: false)
            }
            else {
                onBeforeShowingEditionMenu(editionOption, cell: cell)
                shouldExportMediaAsGIF.toggle()
                onAfterConfirmingEditionMenu()
                analyticsProvider?.logEditorGIFButtonToggle(shouldExportMediaAsGIF)
            }
        case .filter:
            onBeforeShowingEditionMenu(editionOption, cell: cell)
            showMainUI(false)
            analyticsProvider?.logEditorFiltersOpen()
            filterController.showView(true)
        case .text:
            onBeforeShowingEditionMenu(editionOption, cell: cell)
            showMainUI(false)
            analyticsProvider?.logEditorTextAdd()
            editingNewText = true
            textController.showView(true)
            if settings.animateEditorControls {
                editorView.animateEditionOption(cell: cell, finalLocation: textController.confirmButtonLocation, completion: { _ in
                    self.textController.showConfirmButton(true)
                })
            } else {
                self.textController.showConfirmButton(true)
            }
        case .drawing:
            onBeforeShowingEditionMenu(editionOption, cell: cell)
            showMainUI(false)
            analyticsProvider?.logEditorDrawingOpen()
            drawingController.showView(true)
            if settings.animateEditorControls {
                editorView.animateEditionOption(cell: cell, finalLocation: drawingController.confirmButtonLocation, completion: { _ in
                    self.drawingController.showConfirmButton(true)
                })
            } else {
                self.drawingController.showConfirmButton(true)
            }
        case .media:
            onBeforeShowingEditionMenu(editionOption, cell: cell)
            analyticsProvider?.logEditorMediaDrawerOpen()
            openMediaDrawer()
        }
    }
    
    /// Prepares the editor state to show an edition menu
    ///
    /// - Parameters
    ///  - editionOption: the selected edition option
    ///  - cell: the cell of the selected edition option
    private func onBeforeShowingEditionMenu(_ editionOption: EditionOption, cell: KanvasEditorMenuCollectionCell? = nil) {
        selectedCell = cell
        openedMenu = editionOption
    }
    
    // MARK: - GifMakerHandlerDelegate & MediaPlayerDelegate

    func getDefaultTimeIntervalForImageSegments() -> TimeInterval {
        return CameraSegment.defaultTimeInterval(segments: segments)
    }

    // MARK: - GifMakerHandlerDelegate
    
    func didConfirmGif() {
        confirmEditionMenu()
    }

    func didRevertGif() {
        revertGIF()
    }

    func didSettingsChange(dirty: Bool) {
        gifMakerController.toggleRevertButton(dirty)
    }

    func configureMediaPlayer(settings: GIFMakerSettings) {
        player.rate = settings.rate
        player.startMediaIndex = settings.startIndex
        player.endMediaIndex = settings.endIndex
        player.playbackMode = .init(from: settings.playbackMode)
    }

    func setMediaPlayerFrame(location: CGFloat) {
        player.playSingleFrame(at: location)
    }

    func unsetMediaPlayerFrame() {
        player.cancelPlayingSingleFrame()
    }

    // MARK: - EditorFilterControllerDelegate
    
    func didConfirmFilters() {
        confirmEditionMenu()
    }
    
    func didSelectFilter(_ filterItem: FilterItem) {
        analyticsProvider?.logEditorFilterSelected(filterType: filterItem.type)
        self.filterType = filterItem.type
    }
    
    // MARK: - DrawingControllerDelegate
    
    func didConfirmDrawing() {
        analyticsProvider?.logEditorDrawingConfirm()
        confirmEditionMenu()
    }
    
    func editorShouldShowStrokeSelectorAnimation() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowStrokeSelectorAnimation()
    }
    
    func didEndStrokeSelectorAnimation() {
        delegate?.didEndStrokeSelectorAnimation()
    }
    
    // MARK: - EditorTextControllerDelegate
    
    func didConfirmText(textView: StylableTextView, transformations: ViewTransformations, location: CGPoint, size: CGSize) {
        if !textView.text.isEmpty {
            editorView.movableViewCanvas.addView(view: textView, transformations: transformations, location: location, size: size, animated: true)
            if let font = textView.options.font, let alignment = KanvasTextAlignment.from(alignment: textView.options.alignment) {
                analyticsProvider?.logEditorTextConfirm(isNew: editingNewText, font: font, alignment: alignment, highlighted: textView.options.highlightColor != nil)
            }
            else {
                assertionFailure("Logging unknown stuff")
            }
        }
        confirmEditionMenu()
    }
    
    func didMoveToolsUp() {
        editorView.movableViewCanvas.removeSelectedView()
    }

    func didChange(font: UIFont) {
        analyticsProvider?.logEditorTextChange(font: font)
    }

    func didChange(highlight: Bool) {
        analyticsProvider?.logEditorTextChange(highlighted: highlight)
    }

    func didChange(alignment: NSTextAlignment) {
        if let alignment = KanvasTextAlignment.from(alignment: alignment) {
            analyticsProvider?.logEditorTextChange(alignment: alignment)
        }
    }

    func didChange(color: Bool) {
        analyticsProvider?.logEditorTextChange(color: true)
    }
    
    // MARK: - DrawingControllerDelegate & EditorTextControllerDelegate
    
    func editorShouldShowColorSelectorTooltip() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowColorSelectorTooltip()
    }
    
    func didDismissColorSelectorTooltip() {
        delegate?.didDismissColorSelectorTooltip()
    }
    
    func didStartColorSelection() {
        drawingController.showCanvas(false)
        editorView.showMovableViewCanvas(false)
    }
    
    func didStartMovingColorSelector() {
        if !player.isMediaOnePhoto() {
            player.pause()
        }
    }
    
    func didEndColorSelection() {
        if !player.isMediaOnePhoto() {
            player.resume()
        }
        drawingController.showCanvas(true)
        editorView.showMovableViewCanvas(true)
    }
    
    func getColor(from point: CGPoint) -> UIColor {
        return player.getColor(from: point)
    }
    
    func didDisplayFirstFrame(_ image: UIImage) {
        addCarouselDefaultColors(image)
    }
    
    // MARK: - MediaDrawerControllerDelegate
    
    func didSelectSticker(imageView: StylableImageView, size: CGSize) {
        analyticsProvider?.logEditorStickerAdd(stickerId: imageView.id)
        editorView.movableViewCanvas.addView(view: imageView, transformations: ViewTransformations(),
                                             location: editorView.movableViewCanvas.bounds.center, size: size, animated: true)
    }
    
    func didSelectStickerType(_ stickerType: StickerType) {
        analyticsProvider?.logEditorStickerPackSelect(stickerPackId: stickerType.id)
    }
    
    func didDismissMediaDrawer() {
        confirmEditionMenu()
    }
    
    func didSelectStickersTab() {
        analyticsProvider?.logEditorMediaDrawerSelectStickers()
    }
    
    // MARK: - Media Drawer
    
    private func openMediaDrawer() {
        present(mediaDrawerController, animated: true, completion: .none)
    }
    
    // MARK: - MediaPlayerController
    
    func onPostingOptionsDismissed() {
        startPlayerFromSegments()
    }
    
    func onQuickPostButtonSubmitted() {
        startExporting(action: .confirmPostOptions)
    }
    
    public func onQuickPostOptionsShown(visible: Bool, hintText: String?, view: UIView) {
        editorView.moveOverlayLabel(to: view)
        
        if visible {
            editorView.setOverlayLabel(text: hintText)
            editorView.moveViewToFront(view, visible: true)
            editorView.showOverlay(true)
        }
        else {
            editorView.showOverlay(false, completion: { [weak self] _ in
                self?.editorView.moveViewToFront(view, visible: false)
                self?.editorView.setOverlayLabel(text: hintText)
            })
        }
    }
    
    public func onQuickPostOptionsSelected(selected: Bool, hintText: String?, view: UIView) {
        editorView.setOverlayLabel(text: hintText)
    }
    
    // MARK: - Private utilities
    
    /// shows or hides the main UI (edition options, tag button and back button)
    ///
    /// - Parameter show: true to show, false to hide
    private func showMainUI(_ show: Bool) {
        collectionController.showView(show)
        showConfirmButton(show)
        showCloseButton(show)
        showTagButton(show)
        showTagCollection(show)
    }
    
    // MARK: - Public interface
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        editorView.showConfirmButton(show)
    }
    
    /// shows or hides the close button (back caret)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseButton(_ show: Bool) {
        editorView.showCloseButton(show)
    }

    /// shows or hides the tag button (#)
    ///
    /// - Parameter show: true to show, false to hide
    func showTagButton(_ show: Bool) {
        editorView.showTagButton(show)
    }
    
    /// shows or hides the tag collection
    ///
    /// - Parameter show: true to show, false to hide
    func showTagCollection(_ show: Bool) {
        editorView.showTagCollection(show)
    }
    
    /// shows or hides the editor menu and the back button
    ///
    /// - Parameter show: true to show, false to hide
    func showNavigationContainer(_ show: Bool) {
        editorView.showNavigationContainer(show)
    }
}
