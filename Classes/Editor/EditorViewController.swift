//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit
import Utils

/// Protocol for camera editor controller methods

public protocol EditorControllerDelegate: class {
    /// callback when finished exporting video clips.
    func didFinishExportingVideo(url: URL?, info: TumblrMediaInfo?, action: KanvasExportAction, mediaChanged: Bool)
    
    /// callback when finished exporting image
    func didFinishExportingImage(image: UIImage?, info: TumblrMediaInfo?, action: KanvasExportAction, mediaChanged: Bool)
    
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
}

private struct Constants {
    static let pageName: String = "KanvasEditor"
    static let stickerHitAreaOffset: CGFloat = 10
}

/// A view controller to edit the segments
public final class EditorViewController: UIViewController, MediaPlayerController, EditorViewDelegate, EditionMenuCollectionControllerDelegate, EditorFilterControllerDelegate, DrawingControllerDelegate, EditorTextControllerDelegate, MediaDrawerControllerDelegate, MediaPlayerDelegate {

    private lazy var editorView: EditorView = {
        var mainActionMode: EditorView.MainActionMode = .confirm
        if settings.features.editorPostOptions {
            mainActionMode = .postOptions
        }
        else if settings.features.editorPosting {
            mainActionMode = .post
        }

        let editorView = EditorView(mainActionMode: mainActionMode,
                                    showSaveButton: settings.features.editorSaving,
                                    showCrossIcon: settings.crossIconInEditor,
                                    showTagButton: settings.showTagButtonInEditor,
                                    quickBlogSelectorCoordinator: quickBlogSelectorCoordinater)
        editorView.delegate = self
        player.playerView = editorView.playerView
        return editorView
    }()
    
    private lazy var collectionController: EditionMenuCollectionController = {
        let controller = EditionMenuCollectionController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    
    private lazy var filterController: EditorFilterController = {
        let controller = EditorFilterController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    
    private lazy var textController: EditorTextController = {
        let controller = EditorTextController()
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
    
    private lazy var loadingView: LoadingIndicatorView = LoadingIndicatorView()

    private let quickBlogSelectorCoordinater: KanvasQuickBlogSelectorCoordinating?
    private let analyticsProvider: KanvasCameraAnalyticsProvider?
    private let settings: CameraSettings
    private let segments: [CameraSegment]
    private let assetsHandler: AssetsHandlerType
    private let exporterClass: MediaExporting.Type
    private let stickerProvider: StickerProvider?
    private let cameraMode: CameraMode?
    private var openedMenu: EditionOption?
    private var selectedCell: EditionMenuCollectionCell?

    private let player: MediaPlayer
    private var filterType: FilterType? {
        didSet {
            player.filterType = filterType
        }
    }
    
    private var mediaChanged: Bool {
        let hasStickerOrText = !editorView.movableViewCanvas.isEmpty
        let filterApplied = filterType?.filterApplied == true
        let hasDrawings = !drawingController.isEmpty
        return hasStickerOrText || filterApplied || hasDrawings
    }

    private var editingNewText: Bool = true

    public weak var delegate: EditorControllerDelegate?
    
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
                             segments: [.image(image, nil, nil, TumblrMediaInfo(source: .media_library))],
                             assetsHandler: CameraSegmentHandler(),
                             exporterClass: MediaExporter.self,
                             cameraMode: nil,
                             stickerProvider: stickerProvider,
                             analyticsProvider: analyticsProvider,
                             quickBlogSelectorCoordinator: nil)
    }
    
    public static func createEditor(for videoURL: URL, settings: CameraSettings, stickerProvider: StickerProvider) -> EditorViewController {
        EditorViewController(settings: settings,
                             segments: [.video(videoURL, TumblrMediaInfo(source: .media_library))],
                             assetsHandler: CameraSegmentHandler(),
                             exporterClass: MediaExporter.self,
                             cameraMode: nil,
                             stickerProvider: stickerProvider,
                             analyticsProvider: nil,
                             quickBlogSelectorCoordinator: nil)
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
         cameraMode: CameraMode?,
         stickerProvider: StickerProvider?,
         analyticsProvider: KanvasCameraAnalyticsProvider?,
         quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?) {
        self.settings = settings
        self.segments = segments
        self.assetsHandler = assetsHandler
        self.cameraMode = cameraMode
        self.analyticsProvider = analyticsProvider
        self.exporterClass = exporterClass
        self.stickerProvider = stickerProvider
        self.quickBlogSelectorCoordinater = quickBlogSelectorCoordinator

        self.player = MediaPlayer(renderer: Renderer())
        super.init(nibName: .none, bundle: .none)
        
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
        startPlayer()
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
    
    // MARK: - EditorViewDelegate
    
    func didTapSaveButton() {
        startExporting(action: .save)
        analyticsProvider?.logSaveFromDashboard()
    }

    func didTapPostButton() {
        startExporting(action: .post)
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
        let cell = collectionController.textCell
        onBeforeShowingEditionMenu(.text, cell: cell)
        showMainUI(false)
        textController.showView(true, options: options, transformations: transformations)
        editorView.animateEditionOption(cell: cell, finalLocation: textController.confirmButtonLocation, completion: {
            self.textController.showConfirmButton(true)
        })
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
    
    /// Loads the media into the player and starts it.
    private func startPlayer() {
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
    
    private func startExporting(action: KanvasExportAction) {
        player.stop()
        showLoading()
        if segments.count == 1, let firstSegment = segments.first, let image = firstSegment.image {
            // If the camera mode is .stopMotion, .normal or .stitch (.video) and the `exportStopMotionPhotoAsVideo` is true,
            // then single photos from that mode should still export as video.
            if let cameraMode = cameraMode, cameraMode.group == .video && settings.exportStopMotionPhotoAsVideo, let videoURL = firstSegment.videoURL {
                createFinalVideo(videoURL: videoURL, mediaInfo: firstSegment.mediaInfo, exportAction: action)
            }
            else {
                createFinalImage(image: image, mediaInfo: firstSegment.mediaInfo, exportAction: action)
            }
        }
        else {
            assetsHandler.mergeAssets(segments: segments) { [weak self] url, mediaInfo in
                guard let url = url else {
                    self?.hideLoading()
                    self?.handleExportError()
                    return
                }
                self?.createFinalVideo(videoURL: url, mediaInfo: mediaInfo ?? TumblrMediaInfo(source: .media_library), exportAction: action)
            }
        }
    }

    private func createFinalVideo(videoURL: URL, mediaInfo: TumblrMediaInfo, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init()
        exporter.filterType = filterType ?? .passthrough
        exporter.imageOverlays = imageOverlays()
        exporter.export(video: videoURL, mediaInfo: mediaInfo) { (exportedVideoURL, _) in
            performUIUpdate {
                guard let url = exportedVideoURL else {
                    self.hideLoading()
                    self.handleExportError()
                    return
                }
                self.delegate?.didFinishExportingVideo(url: url, info: mediaInfo, action: exportAction, mediaChanged: self.mediaChanged)
                self.hideLoading()
            }
        }
    }

    private func createFinalImage(image: UIImage, mediaInfo: TumblrMediaInfo, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init()
        exporter.filterType = filterType ?? .passthrough
        exporter.imageOverlays = imageOverlays()
        exporter.export(image: image, time: player.lastStillFilterTime) { (exportedImage, _) in
            performUIUpdate {
                guard TARGET_OS_SIMULATOR == 0 else {
                    self.delegate?.didFinishExportingImage(image: UIImage(), info: mediaInfo, action: exportAction, mediaChanged: self.mediaChanged)
                    self.hideLoading()
                    return
                }
                guard let unwrappedImage = exportedImage else {
                    self.hideLoading()
                    self.handleExportError()
                    return
                }
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
        
        editorView.movableViewCanvas.updateLayer()
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
    
    func didTapCloseButton() {
        player.stop()
        delegate?.dismissButtonPressed()
    }
    
    func confirmEditionMenu() {
        guard let editionOption = openedMenu else { return }
        
        switch editionOption {
        case .filter:
            filterController.showView(false)
            showMainUI(true)
        case .text:
            editorView.animateReturnOfEditionOption(cell: selectedCell)
            textController.showView(false)
            textController.showConfirmButton(false)
            showMainUI(true)
        case .drawing:
            editorView.animateReturnOfEditionOption(cell: selectedCell)
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
    
    // MARK: - EditionMenuCollectionControllerDelegate
    
    func didSelectEditionOption(_ editionOption: EditionOption, cell: EditionMenuCollectionCell) {
        onBeforeShowingEditionMenu(editionOption, cell: cell)
        
        switch editionOption {
        case .filter:
            showMainUI(false)
            analyticsProvider?.logEditorFiltersOpen()
            filterController.showView(true)
        case .text:
            showMainUI(false)
            analyticsProvider?.logEditorTextAdd()
            editingNewText = true
            textController.showView(true)
            editorView.animateEditionOption(cell: cell, finalLocation: textController.confirmButtonLocation, completion: {
                self.textController.showConfirmButton(true)
            })
        case .drawing:
            showMainUI(false)
            analyticsProvider?.logEditorDrawingOpen()
            drawingController.showView(true)
            editorView.animateEditionOption(cell: cell, finalLocation: drawingController.confirmButtonLocation, completion: {
                self.drawingController.showConfirmButton(true)
            })
        case .media:
            analyticsProvider?.logEditorMediaDrawerOpen()
            openMediaDrawer()
        }
    }
    
    /// Prepares the editor state to show an edition menu
    ///
    /// - Parameters
    ///  - editionOption: the selected edition option
    ///  - cell: the cell of the selected edition option
    private func onBeforeShowingEditionMenu(_ editionOption: EditionOption, cell: EditionMenuCollectionCell? = nil) {
        selectedCell = cell
        openedMenu = editionOption
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
            editorView.movableViewCanvas.addView(view: textView, transformations: transformations, location: location, size: size)
            if let font = KanvasTextFont.from(font: textView.options.font), let alignment = KanvasTextAlignment.from(alignment: textView.options.alignment) {
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
        if let font = KanvasTextFont.from(font: font) {
            analyticsProvider?.logEditorTextChange(font: font)
        }
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
                                             location: editorView.movableViewCanvas.bounds.center,
                                             size: size, additionalHitArea: Constants.stickerHitAreaOffset)
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
        startPlayer()
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
    
    /// shows or hides the editor menu and the back button
    ///
    /// - Parameter show: true to show, false to hide
    func showNavigationContainer(_ show: Bool) {
        editorView.showNavigationContainer(show)
    }
}
