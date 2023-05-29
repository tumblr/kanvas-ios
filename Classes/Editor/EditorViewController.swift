//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit
import CropViewController

/// Protocol for camera editor controller methods

public protocol EditorControllerDelegate: AnyObject {
    /// callback when finished exporting video clips.
    func didFinishExportingVideo(url: URL?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool)

    /// callback when finished exporting image
    func didFinishExportingImage(image: UIImage?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool)

    /// callback when finished exporting frames
    func didFinishExportingFrames(url: URL?, size: CGSize?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool)

    /// callback when exporting fails
    func didFailExporting()
    
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
    
    /// Obtains the quick post button.
    ///
    /// - Returns: the quick post button.
    func getQuickPostButton() -> UIView
    
    /// Obtains the blog switcher.
    ///
    /// - Returns: the blog switcher.
    func getBlogSwitcher() -> UIView

    /// Called when the Post Button is pressed to indicate whether export should occur
    /// The return value indicates whether the export should be run
    /// This is partly temporary, I think the export functionality should be passed into this controller to decouple things
    func shouldExport() -> Bool

    /// Called when the editor screen has become visible.
    func editorDidAppear()

    /// Called when the editor screen is not longer visible.
    func editorWillDisappear()
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
public final class EditorViewController: UIViewController, MediaPlayerController, EditorViewDelegate, KanvasEditorMenuControllerDelegate, EditorFilterControllerDelegate, DrawingControllerDelegate, EditorTextControllerDelegate, MediaDrawerControllerDelegate, GifMakerHandlerDelegate, MediaPlayerDelegate, CropViewControllerDelegate {

    enum Media {
        case image(UIImage)
        case video(URL)
    }

    public struct ExportResult {
        let original: Media?
        let result: Media
        let info: MediaInfo
        let archive: Data
    }

    @objc(KanvasEditorEdit) public class Edit: NSObject, NSSecureCoding {
        public static var supportsSecureCoding = true

        public func encode(with coder: NSCoder) {
            coder.encode(canvas, forKey: "canvas")
            coder.encode(isMuted, forKey: "isMuted")
        }

        public required init?(coder: NSCoder) {
            canvas = coder.decodeObject(of: MovableViewCanvas.self, forKey: "canvas")
            isMuted = coder.decodeBool(forKey: "isMuted")
        }

        let canvas: MovableViewCanvas?
        let isMuted: Bool

        init(canvas: MovableViewCanvas, isMuted: Bool) {
            self.canvas = canvas
            self.isMuted = isMuted
        }
    }

    // Set immediately after the initializer super call to ensure it is never `nil`.
    var editorView: EditorView!

    var isMuted: Bool {
        return player.isMuted
    }
    
    private lazy var collectionController: KanvasEditorMenuController = {
        let exportAsGif = shouldEnableGIFButton() ? shouldExportAsGIFByDefault() : nil
        let controller: KanvasEditorMenuController
        
        if KanvasEditorDesign.shared.isVerticalMenu {
            controller = StyleMenuController(settings: self.settings, shouldExportMediaAsGIF: exportAsGif)
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
        let textViewSettings = EditorTextView.Settings(fontSelectorUsesFont: settings.fontSelectorUsesFont, resizesFonts: settings.features.resizesFonts)
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
    private let analyticsProvider: KanvasAnalyticsProvider?
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
    
    private var cropRotateApplied: Bool = false
    
    private var mediaChanged: Bool {
        let hasStickerOrText = !editorView.movableViewCanvas.isEmpty
        let filterApplied = filterType?.filterApplied ?? false
        let hasDrawings = !drawingController.isEmpty
        let gifMakerOpened = shouldExportMediaAsGIF
        return hasStickerOrText || filterApplied || hasDrawings || gifMakerOpened || cropRotateApplied
    }

    private var editingNewText: Bool = true

    public weak var delegate: EditorControllerDelegate?

    private var exportCompletion: ((Result<ExportResult, Error>) -> Void)?

    private static func editor(delegate: EditorViewDelegate?,
                               settings: CameraSettings,
                               showsMuteButton: Bool,
                               edit: Edit?,
                               quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?,
                               tagCollection: UIView?,
                               metalContext: MetalContext?) -> EditorView {
        var mainActionMode: EditorView.MainActionMode = .confirm
        if settings.features.editorPostOptions {
            mainActionMode = .postOptions
        }
        else if settings.features.editorPosting {
            mainActionMode = .post
        }

        let canvas = edit?.canvas ?? MovableViewCanvas()

        let editorView: EditorView = EditorView(delegate: delegate,
                                    mainActionMode: mainActionMode,
                                    showSaveButton: settings.features.editorSaving,
                                    showMuteButton: showsMuteButton,
                                    showCrossIcon: settings.crossIconInEditor,
                                    showCogIcon: settings.showCogIconInEditor,
                                    showTagButton: settings.showTagButtonInEditor,
                                    showTagCollection: settings.showTagCollectionInEditor,
                                    showQuickPostButton: settings.showQuickPostButtonInEditor,
                                    showBlogSwitcher: settings.showBlogSwitcherInEditor,
                                    confirmAtTop: settings.features.editorConfirmAtTop,
                                    aspectRatio: settings.aspectRatio,
                                    quickBlogSelectorCoordinator: quickBlogSelectorCoordinator,
                                    tagCollection: tagCollection,
                                    metalContext: metalContext,
                                    mediaContentMode: settings.features.scaleMediaToFill ? .scaleAspectFill : .scaleAspectFit,
                                    movableViewCanvas: canvas)
        canvas.delegate = editorView
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
                                    analyticsProvider: KanvasAnalyticsProvider,
                                    delegate: EditorControllerDelegate) -> EditorViewController {
        EditorViewController(delegate: delegate,
                             settings: settings,
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
    
    public static func createEditor(for videoURL: URL,
                                    settings: CameraSettings,
                                    stickerProvider: StickerProvider,
                                    delegate: EditorControllerDelegate) -> EditorViewController {
        EditorViewController(delegate: delegate,
                             settings: settings,
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
                              analyticsProvider: KanvasAnalyticsProvider,
                              delegate: EditorControllerDelegate,
                              completion: @escaping (EditorViewController) -> Void) {
        GIFDecoderFactory.main().decode(image: url) { frames in
            let segments = CameraSegment.from(frames: frames, info: info)
            let editor = EditorViewController(delegate: delegate,
                                              settings: settings,
                                              segments: segments,
                                              stickerProvider: stickerProvider,
                                              analyticsProvider: analyticsProvider)
            completion(editor)
        }
    }

    convenience init(delegate: EditorControllerDelegate,
                     settings: CameraSettings,
                     segments: [CameraSegment],
                     stickerProvider: StickerProvider,
                     analyticsProvider: KanvasAnalyticsProvider) {
        self.init(delegate: delegate,
                  settings: settings,
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
    ///   - analyticsProvider: A class conforming to KanvasAnalyticsProvider
    init(delegate: EditorControllerDelegate,
         settings: CameraSettings,
         segments: [CameraSegment],
         assetsHandler: AssetsHandlerType,
         exporterClass: MediaExporting.Type,
         gifEncoderClass: GIFEncoder.Type,
         cameraMode: CameraMode?,
         stickerProvider: StickerProvider?,
         analyticsProvider: KanvasAnalyticsProvider?,
         quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?,
         edit: Edit? = nil,
         tagCollection: UIView?) {
        self.delegate = delegate
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

        let metalContext: MetalContext? = settings.features.metalPreview ? MetalContext.createContext() : nil
        self.player = MediaPlayer(renderer: Renderer(settings: settings, metalContext: metalContext))
        self.player.isMuted = edit?.isMuted == true
        let muteButtonShown = settings.features.muteButton && segments.first?.isVideo == true

        super.init(nibName: .none, bundle: .none)

        self.editorView = EditorViewController.editor(delegate: self,
                                                      settings: settings,
                                                      showsMuteButton: muteButtonShown,
                                                      edit: edit,
                                                      quickBlogSelectorCoordinator: quickBlogSelectorCoordinator,
                                                      tagCollection: tagCollection,
                                                      metalContext: metalContext)
        self.editorView.muteButtonSelected = player.isMuted

        player.playerView = editorView.playerView
        
        self.player.delegate = self

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

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.editorWillDisappear()
        player.pause()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.editorDidAppear()
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
        let media: [MediaPlayerContent] = segments.compactMap {segment in
            if let image = segment.image {
                return .image(image, segment.timeInterval)
            }
            else if let url = segment.videoURL {
                return .video(url)
            }
            else {
                return nil
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
            editorView.showQuickPostButton(false)
            gifMakerController.showConfirmButton(true)
        }
        analyticsProvider?.logEditorGIFOpen()
    }

    private func revertGIF() {
        if settings.animateEditorControls {
            editorView.animateReturnOfEditionOption(cell: selectedCell, initialLocation: gifMakerController.confirmButtonLocation)
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
        if segments.count > 1 || segments.first?.isVideo == true {
            return true
        }

        // A single segment that has both an image and a video (live photo), enabled it.
        if segments.count == 1,
            let firstSegment = segments.first,
            firstSegment.isVideo == false,
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
    }

    func didTapPostButton() {
        if delegate?.shouldExport() ?? true {
            startExporting(action: .post)
        }
        analyticsProvider?.logPostFromDashboard()
    }

    func didTapConfirmButton() {
        if delegate?.shouldExport() ?? true {
            startExporting(action: .confirm)
        }
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
        editorView.showNavigationItems(false)
    }
    
    func didEndTouchesOnText() {
        editorView.showNavigationItems(true)
    }

    func didRenderRectChange(rect: CGRect) {
        drawingController.didRenderRectChange(rect: rect)
    }

    func didTapCloseButton() {
        player.stop()
        delegate?.dismissButtonPressed()
    }

    func getBlogSwitcher() -> UIView {
        guard let delegate = delegate else { return UIView() }
        return delegate.getBlogSwitcher()
    }
    
    func getQuickPostButton() -> UIView {
        guard let delegate = delegate else { return UIView() }
        return delegate.getQuickPostButton()
    }

    func restartPlayback() {
        player.stop()
        startPlayerFromSegments()
    }
    
    func stopPlayback() {
        player.stop()
    }

    deinit {
        player.stop()
    }
    
    // MARK: - Media Exporting

    private func startExporting(action: KanvasExportAction) {
        player.stop()
        showLoading()
        let archive: Data
        do {
            archive = try NSKeyedArchiver.archivedData(withRootObject: edit, requiringSecureCoding: true)
        } catch {
            handleExportError()
            return
        }
        if segments.count == 1, let firstSegment = segments.first, case CameraSegment.image(let image, _, _, _) = firstSegment {
            // If the camera mode is .stopMotion, or .stitch (.video) and the `exportStopMotionPhotoAsVideo` is true,
            // then single photos from that mode should still export as video.
            if let cameraMode = cameraMode, cameraMode.group == .video && cameraMode != .normal && settings.exportStopMotionPhotoAsVideo {
                assetsHandler.ensureAllImagesHaveVideo(segments: segments) { segments in
                    guard let videoURL = segments.first?.videoURL else { return }
                    DispatchQueue.main.async {
                        self.createFinalVideo(videoURL: videoURL, mediaInfo: firstSegment.mediaInfo, archive: archive, exportAction: action)
                    }
                }
            }
            else {
                createFinalImage(image: image, mediaInfo: firstSegment.mediaInfo, archive: archive, exportAction: action)
            }
        }
        else if shouldExportMediaAsGIF {
            if segments.count == 1, let segment = segments.first, let url = segment.videoURL {
                self.createFinalGIF(videoURL: url, framesPerSecond: KanvasTimes.gifPreferredFramesPerSecond, mediaInfo: segment.mediaInfo, archive: archive, exportAction: action)
            }
            else if assetsHandler.containsOnlyImages(segments: segments) {
                self.createFinalGIF(segments: segments, mediaInfo: segments.first?.mediaInfo ?? MediaInfo(source: .kanvas_camera), archive: archive, exportAction: action)
            }
            else {
                // Segments are not all frames, so we need to generate a full video first, and then convert that to a GIF.
                // It might be nice in the future to create a GIF directly from segments.
                assetsHandler.mergeAssets(segments: segments, withAudio: true) { [weak self] url, mediaInfo in
                    guard let self = self else {
                        return
                    }
                    guard let url = url, let mediaInfo = mediaInfo else {
                        self.handleExportError()
                        return
                    }
                    let fps = Int(CMTime(seconds: 1.0, preferredTimescale: KanvasTimes.stopMotionFrameTimescale).seconds / KanvasTimes.onlyImagesFrameTime.seconds)
                    DispatchQueue.main.async {
                        self.createFinalGIF(videoURL: url, framesPerSecond: fps, mediaInfo: mediaInfo, archive: archive, exportAction: action)
                    }
                }
            }
        }
        else {
            assetsHandler.mergeAssets(segments: segments, withAudio: isMuted == false) { [weak self] url, mediaInfo in
                guard let url = url else {
                    self?.handleExportError()
                    return
                }
                DispatchQueue.main.async {
                    self?.createFinalVideo(videoURL: url, mediaInfo: mediaInfo ?? MediaInfo(source: .media_library), archive: archive, exportAction: action)
                }
            }
        }
    }

    public func export(_ completion: @escaping (Result<ExportResult, Error>) -> Void) {
        exportCompletion = completion
        startExporting(action: .post)
    }

    var edit: Edit {
        return Edit(canvas: editorView.movableViewCanvas, isMuted: isMuted)
    }

    private var exportSize: CGSize? {
        let exportSize = editorView.exportSize
        return settings.features.scaleMediaToFill ? exportSize : nil
    }

    private func createFinalGIF(segments: [CameraSegment], mediaInfo: MediaInfo, archive: Data, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init(settings: settings)
        exporter.filterType = filterType ?? .passthrough
        exporter.imageOverlays = imageOverlays()
        let segments = gifMakerHandler.trimmedSegments(segments)
        let frames = segments.compactMap { $0.mediaFrame(defaultTimeInterval: getDefaultTimeIntervalForImageSegments()) }
        exporter.export(frames: frames, toSize: exportSize) { orderedFrames in
            let playbackFrames = self.gifMakerHandler.framesForPlayback(orderedFrames)
            self.gifEncoderClass.init().encode(frames: playbackFrames, loopCount: 0) { gifURL in
                guard let gifURL = gifURL else {
                    performUIUpdate {
                        self.handleExportError()
                    }
                    return
                }
                let size = GIFDecoderFactory.main().size(of: gifURL)
                let result = ExportResult(original: nil, result: .video(gifURL), info: mediaInfo, archive: archive)
                self.exportCompletion?(.success(result))
                self.delegate?.didFinishExportingFrames(url: gifURL, size: size, info: mediaInfo, archive: archive, action: exportAction, mediaChanged: self.mediaChanged)
            }
        }
    }

    private func createFinalGIF(videoURL: URL, framesPerSecond: Int, mediaInfo: MediaInfo, archive: Data, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init(settings: settings)
        exporter.filterType = filterType ?? .passthrough
        exporter.imageOverlays = imageOverlays()
        exporter.export(video: videoURL, mediaInfo: mediaInfo, toSize: exportSize) { (exportedVideoURL, _) in
            guard let exportedVideoURL = exportedVideoURL else {
                performUIUpdate {
                    self.handleExportError()
                }
                return
            }
            self.gifEncoderClass.init().encode(video: exportedVideoURL, loopCount: 0, framesPerSecond: framesPerSecond) { gifURL in
                guard let gifURL = gifURL else {
                    performUIUpdate {
                        self.handleExportError()
                    }
                    return
                }
                let size = GIFDecoderFactory.main().size(of: gifURL)
                let result = ExportResult(original: nil, result: .video(gifURL), info: mediaInfo, archive: archive)
                self.exportCompletion?(.success(result))
                self.delegate?.didFinishExportingFrames(url: gifURL, size: size, info: mediaInfo, archive: archive, action: exportAction, mediaChanged: self.mediaChanged)
            }
        }
    }

    private func createFinalVideo(videoURL: URL, mediaInfo: MediaInfo, archive: Data, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init(settings: settings)
        exporter.filterType = filterType ?? .passthrough
        exporter.imageOverlays = imageOverlays()
        exporter.export(video: videoURL, mediaInfo: mediaInfo, toSize: exportSize) { (exportedVideoURL, error) in
            performUIUpdate {
                guard let url = exportedVideoURL else {
                    if let error = error, let exportCompletion = self.exportCompletion {
                        exportCompletion(.failure(error))
                    } else {
                        self.handleExportError()
                    }
                    return
                }
                let result = ExportResult(original: .video(videoURL), result: .video(url), info: mediaInfo, archive: archive)
                self.exportCompletion?(.success(result))
                self.delegate?.didFinishExportingVideo(url: url, info: mediaInfo, archive: archive, action: exportAction, mediaChanged: self.mediaChanged)
            }
        }
    }

    private func createFinalImage(image: UIImage, mediaInfo: MediaInfo, archive: Data, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init(settings: settings)
        exporter.filterType = filterType ?? .passthrough
        exporter.imageOverlays = imageOverlays()
        exporter.export(image: image, time: player.lastStillFilterTime, toSize: exportSize) { (exportedImage, error) in
            let originalImage = image
            performUIUpdate {
                guard let unwrappedImage = exportedImage else {
                    if let error = error, let exportCompletion = self.exportCompletion {
                        exportCompletion(.failure(error))
                    } else {
                        self.handleExportError()
                    }
                    return
                }
                let result = ExportResult(original: .image(originalImage), result: .image(unwrappedImage), info: mediaInfo, archive: archive)
                self.exportCompletion?(.success(result))
                self.delegate?.didFinishExportingImage(image: unwrappedImage, info: mediaInfo, archive: archive, action: exportAction, mediaChanged: self.mediaChanged)
            }
        }
    }

    private func imageOverlays() -> [CGImage] {
        editorView.layoutIfNeeded()
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
        delegate?.didFailExporting()
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
                editorView.animateReturnOfEditionOption(cell: selectedCell, initialLocation: gifMakerController.confirmButtonLocation)
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
            editorView.showQuickPostButton(true)
            showMainUI(true)
        case .text:
            if settings.animateEditorControls {
            editorView.animateReturnOfEditionOption(cell: selectedCell, initialLocation: textController.confirmButtonLocation)
            } else {
                selectedCell?.alpha = 1
            }
            textController.showView(false)
            textController.showConfirmButton(false)
            showMainUI(true)
        case .drawing:
            if settings.animateEditorControls {
            editorView.animateReturnOfEditionOption(cell: selectedCell, initialLocation: drawingController.confirmButtonLocation)
            } else {
                selectedCell?.alpha = 1
            }
            drawingController.showView(false)
            drawingController.showConfirmButton(false)
            showMainUI(true)
        case .media:
            analyticsProvider?.logEditorMediaDrawerClosed()
        case .cropRotate:
            break
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
            editorView.showQuickPostButton(false)
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
        case .cropRotate:
            onBeforeShowingEditionMenu(editionOption, cell: cell)
            analyticsProvider?.logEditorCropRotateOpen()
            showCropRotateController()
            break
        }
    }
    
    private func showCropRotateController() {
        guard let image: UIImage = segments.first?.image else {
            return
        }
        let cropViewController = CropViewController(image: image)
        cropViewController.aspectRatioLockDimensionSwapEnabled = true
        cropViewController.delegate = self
        cropRotateApplied = false
        present(cropViewController, animated: true, completion: nil)
    }
    
    // MARK: CropViewControllerDelegate
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        originalSegments = [CameraSegment.image(image, nil, nil, MediaInfo(source: .media_library))]
        player.playerView?.reset()
        player.renderer.refreshFilter()
        restartPlayback()
        cropRotateApplied = true
        dismiss(animated: true)
        onAfterConfirmingEditionMenu()
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
        hideLoading()
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
        editorView.showConfirmButton(show)
        editorView.showCloseButton(show)
        editorView.showTagButton(show)
        editorView.showTagCollection(show)
        editorView.showBlogSwitcher(show)
    }
}
