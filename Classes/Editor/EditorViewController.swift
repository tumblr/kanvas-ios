//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import SharedUI
import Foundation
import UIKit

/// Protocol for camera editor controller methods

protocol EditorControllerDelegate: class {
    /// callback when finished exporting video clips.
    func didFinishExportingVideo(url: URL?, action: KanvasExportAction)
    
    /// callback when finished exporting image
    func didFinishExportingImage(image: UIImage?, action: KanvasExportAction)
    
    /// callback when dismissing controller without exporting
    func dismissButtonPressed()
    
    /// Called after the color selecter tooltip is dismissed
    func didDismissColorSelecterTooltip()
    
    /// Called to ask if color selecter tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func editorShouldShowColorSelecterTooltip() -> Bool
    
    /// Called after the stroke animation has ended
    func didEndStrokeSelectorAnimation()
    
    /// Called to ask if stroke selector animation should be shown
    ///
    /// - Returns: Bool for animation
    func editorShouldShowStrokeSelectorAnimation() -> Bool
}

/// A view controller to edit the segments
final class EditorViewController: UIViewController, EditorViewDelegate, EditionMenuCollectionControllerDelegate, EditorFilterControllerDelegate, DrawingControllerDelegate, EditorTextControllerDelegate, GLPlayerDelegate {
    
    private lazy var editorView: EditorView = {
        let editorView = EditorView(mainActionMode: settings.features.editorPosting ? .post : .confirm,
                                    showSaveButton: settings.features.editorSaving)
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
    
    private lazy var loadingView: LoadingIndicatorView = LoadingIndicatorView()

    private let analyticsProvider: KanvasCameraAnalyticsProvider?
    private let settings: CameraSettings
    private let segments: [CameraSegment]
    private let assetsHandler: AssetsHandlerType
    private let exporterClass: MediaExporting.Type
    private let cameraMode: CameraMode?
    private var openedMenu: EditionOption?

    private let player: GLPlayer
    private var filterType: FilterType? {
        didSet {
            player.filterType = filterType
        }
    }

    weak var delegate: EditorControllerDelegate?
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    /// The designated initializer for the editor controller
    ///
    /// - Parameters:
    ///   - settings: The CameraSettings instance for export optioins
    ///   - segments: The segments to playback
    ///   - assetsHandler: The assets handler type, for testing.
    ///   - cameraMode: The camera mode that the preview was coming from, if any
    init(settings: CameraSettings, segments: [CameraSegment], assetsHandler: AssetsHandlerType, exporterClass: MediaExporting.Type, cameraMode: CameraMode?, analyticsProvider: KanvasCameraAnalyticsProvider?) {
        self.settings = settings
        self.segments = segments
        self.assetsHandler = assetsHandler
        self.cameraMode = cameraMode
        self.analyticsProvider = analyticsProvider
        self.exporterClass = exporterClass

        self.player = GLPlayer(renderer: GLRenderer())
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let media: [GLPlayerMedia] = segments.compactMap {segment in
            if let image = segment.image {
                return GLPlayerMedia.image(image)
            }
            else if let url = segment.videoURL {
                return GLPlayerMedia.video(url)
            }
            else {
                return nil
            }
        }
        player.play(media: media)
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
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: - Views
    
    /// Sets up the carousel with the dominant colors from the image on the player
    private func addCarouselDefaultColors(_ image: UIImage) {
        let dominantColors = image.getDominantColors(count: 3)
        drawingController.addColorsForCarousel(colors: dominantColors)
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

    private func startExporting(action: KanvasExportAction) {
        player.stop()
        showLoading()
        if segments.count == 1, let firstSegment = segments.first, let image = firstSegment.image {
            // If the camera mode is .stopMotion, .normal or .stitch (.video) and the `exportStopMotionPhotoAsVideo` is true,
            // then single photos from that mode should still export as video.
            if let cameraMode = cameraMode, cameraMode.group == .video && settings.exportStopMotionPhotoAsVideo, let videoURL = firstSegment.videoURL {
                createFinalVideo(videoURL: videoURL, exportAction: action)
            }
            else {
                createFinalImage(image: image, exportAction: action)
            }
        }
        else {
            assetsHandler.mergeAssets(segments: segments) { [weak self] url in
                guard let url = url else {
                    self?.hideLoading()
                    self?.handleExportError()
                    return
                }
                self?.createFinalVideo(videoURL: url, exportAction: action)
            }
        }
    }

    private func createFinalVideo(videoURL: URL, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init()
        exporter.filterType = filterType
        exporter.imageOverlays = imageOverlays()
        exporter.export(video: videoURL) { (exportedVideoURL, _) in
            performUIUpdate {
                guard let url = exportedVideoURL else {
                    self.hideLoading()
                    self.handleExportError()
                    return
                }
                self.delegate?.didFinishExportingVideo(url: url, action: exportAction)
                self.hideLoading()
            }
        }
    }

    private func createFinalImage(image: UIImage, exportAction: KanvasExportAction) {
        let exporter = exporterClass.init()
        exporter.filterType = filterType
        exporter.imageOverlays = imageOverlays()
        exporter.export(image: image) { (exportedImage, _) in
            performUIUpdate {
                guard let image = exportedImage else {
                    self.hideLoading()
                    self.handleExportError()
                    return
                }
                self.delegate?.didFinishExportingImage(image: image, action: exportAction)
                self.hideLoading()
            }
        }
    }

    private func imageOverlays() -> [CGImage] {
        var imageOverlays: [CGImage] = []
        if let drawingLayer = drawingController.drawingLayer, let drawingOverlayImage = drawingLayer.cgImage() {
            imageOverlays.append(drawingOverlayImage)
        }
        
        editorView.textCanvas.updateLayer()
        if let textOverlayImage = editorView.textCanvas.layer.cgImage() {
            imageOverlays.append(textOverlayImage)
        }
        return imageOverlays
    }

    private func handleExportError() {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("SomethingGoofedTitle", comment: "Alert controller message"), preferredStyle: .alert)
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
    
    func closeMenuButtonPressed() {
        guard let editionOption = openedMenu else { return }
        
        switch editionOption {
        case .filter:
            filterController.showView(false)
        case .text:
            textController.showView(false)
        case .drawing:
            drawingController.showView(false)
        case .media:
            break
        }
        
        collectionController.showView(true)
        showConfirmButton(true)
        showCloseButton(true)
    }
    
    // MARK: - EditionMenuCollectionControllerDelegate
    
    func didSelectEditionOption(_ editionOption: EditionOption) {
        openedMenu = editionOption
        collectionController.showView(false)
        showConfirmButton(false)
        showCloseButton(false)
        
        switch editionOption {
        case .filter:
            analyticsProvider?.logEditorFiltersOpen()
            filterController.showView(true)
        case .text:
            textController.showView(true)
        case .drawing:
            analyticsProvider?.logEditorDrawingOpen()
            drawingController.showView(true)
        case .media:
            break
        }
    }
    
    // MARK: - EditorFilterControllerDelegate
    
    func didConfirmFilters() {
        closeMenuButtonPressed()
    }
    
    func didSelectFilter(_ filterItem: FilterItem) {
        analyticsProvider?.logEditorFilterSelected(filterType: filterItem.type)
        self.filterType = filterItem.type
    }
    
    // MARK: - DrawingControllerDelegate
    
    func didConfirmDrawing() {
        analyticsProvider?.logEditorDrawingConfirm()
        closeMenuButtonPressed()
    }
    
    func editorShouldShowColorSelecterTooltip() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowColorSelecterTooltip()
    }
    
    func didDismissColorSelecterTooltip() {
        delegate?.didDismissColorSelecterTooltip()
    }
    
    func editorShouldShowStrokeSelectorAnimation() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowStrokeSelectorAnimation()
    }
    
    func didEndStrokeSelectorAnimation() {
        delegate?.didEndStrokeSelectorAnimation()
    }
    
    func didStartColorSelection() {
        if !player.isMediaOnePhoto() {
            player.pause()
        }
    }
    
    func didEndColorSelection() {
        if !player.isMediaOnePhoto() {
            player.resume()
        }
    }
    
    func getColor(from point: CGPoint) -> UIColor {
        return player.getColor(from: point)
    }
    
    func didDisplayFirstFrame(_ image: UIImage) {
        addCarouselDefaultColors(image)
    }
    
    // MARK: - EditorTextControllerDelegate
    
    func didConfirmText(text: String, size: CGSize) {
        if !text.isEmpty {
            editorView.textCanvas.add(text: text, size: size)
        }
        closeMenuButtonPressed()
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
}
