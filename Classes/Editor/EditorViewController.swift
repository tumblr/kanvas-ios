//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for camera editor controller methods

protocol EditorControllerDelegate: class {
    /// callback when finished exporting video clips.
    func didFinishExportingVideo(url: URL?, exportAction: KanvasExportAction)
    
    /// callback when finished exporting image
    func didFinishExportingImage(image: UIImage?, exportAction: KanvasExportAction)
    
    /// callback when dismissing controller without exporting
    func dismissButtonPressed()
}

/// A view controller to edit the segments
final class EditorViewController: UIViewController, EditorViewDelegate, EditionMenuCollectionControllerDelegate, EditorFilterCollectionControllerDelegate {
    
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
    
    private lazy var filterCollectionController: EditorFilterCollectionController = {
        let controller = EditorFilterCollectionController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    
    private lazy var loadingView: LoadingIndicatorView = LoadingIndicatorView()
    
    private let settings: CameraSettings
    private let segments: [CameraSegment]
    private let assetsHandler: AssetsHandlerType
    private let cameraMode: CameraMode?

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
    init(settings: CameraSettings, segments: [CameraSegment], assetsHandler: AssetsHandlerType, cameraMode: CameraMode?) {
        self.settings = settings
        self.segments = segments
        self.assetsHandler = assetsHandler
        self.cameraMode = cameraMode

        self.player = GLPlayer(renderer: GLRenderer())

        super.init(nibName: .none, bundle: .none)
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
        
        load(childViewController: collectionController, into: editorView.collectionContainer)
        load(childViewController: filterCollectionController, into: editorView.filterCollectionContainer)
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
    
    // MARK: - CameraEditorViewDelegate

    func saveButtonPressed() {
        startExporting(action: .save)
    }

    func postButtonPressed() {
        startExporting(action: .post)
    }

    func confirmButtonPressed() {
        startExporting(action: .save)
    }

    private func startExporting(action: KanvasExportAction) {
        player.stop()
        showLoading()
        if segments.count == 1, let firstSegment = segments.first, let image = firstSegment.image {
            // If the camera mode is .stopMotion and the `exportStopMotionPhotoAsVideo` is true,
            // then single photos from that mode should still export as video.
            if let cameraMode = cameraMode, cameraMode == .stopMotion && settings.exportStopMotionPhotoAsVideo, let videoURL = firstSegment.videoURL {
                createFinalVideo(videoURL: videoURL, exportAction: action)
            }
            else {
                createFinalImage(image: image, exportAction: action)
            }
        }
        else {
            assetsHandler.mergeAssets(segments: segments) { [weak self] url in
                guard let url = url else {
                    self?.handleExportError()
                    return
                }
                self?.createFinalVideo(videoURL: url, exportAction: action)
            }
        }
    }

    private func createFinalVideo(videoURL: URL, exportAction: KanvasExportAction) {
        let exporter = GLMediaExporter(filterType: filterType)
        exporter.export(video: videoURL) { (exportedVideoURL, _) in
            performUIUpdate {
                guard let url = exportedVideoURL else {
                    self.hideLoading()
                    self.handleExportError()
                    return
                }
                self.delegate?.didFinishExportingVideo(url: url, exportAction: exportAction)
                self.hideLoading()
            }
        }
    }

    private func createFinalImage(image: UIImage, exportAction: KanvasExportAction) {
        let exporter = GLMediaExporter(filterType: filterType)
        exporter.export(image: image) { (exportedImage, _) in
            performUIUpdate {
                guard let image = exportedImage else {
                    self.hideLoading()
                    self.handleExportError()
                    return
                }
                self.delegate?.didFinishExportingImage(image: image, exportAction: exportAction)
                self.hideLoading()
            }
        }
    }

    private func handleExportError() {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("SomethingGoofedTitle", comment: "Alert controller message"), preferredStyle: .alert)
        let tryAgainButton = UIAlertAction(title: NSLocalizedString("Try again", comment: "Try creating final content again"), style: .default) { _ in
            alertController.dismiss(animated: true, completion: .none)
        }
        alertController.addAction(tryAgainButton)
        self.present(alertController, animated: true, completion: .none)
    }
    
    func closeButtonPressed() {
        player.stop()
        delegate?.dismissButtonPressed()
    }
    
    func closeMenuButtonPressed() {
        filterCollectionController.showView(false)
        showSelectionCircle(false)
        showCloseMenuButton(false)
        collectionController.showView(true)
        showConfirmButton(true)
        showCloseButton(true)
    }
    
    // MARK: - EditionMenuCollectionControllerDelegate
    
    func didSelectEditionOption(_ editionOption: EditionOption) {
        switch editionOption {
        case .filter:
            collectionController.showView(false)
            showConfirmButton(false)
            showCloseButton(false)
            filterCollectionController.showView(true)
            showSelectionCircle(true)
            showCloseMenuButton(true)
        case .media:
            break
        }
    }
    
    // MARK: - EditorFilterCollectionControllerDelegate
    
    func didSelectFilter(_ filterItem: FilterItem) {
        self.filterType = filterItem.type
    }
    
    // MARK: - Public interface
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        editorView.showConfirmButton(show)
    }
    
    /// shows or hides the button to close a menu (checkmark)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseMenuButton(_ show: Bool) {
        editorView.showCloseMenuButton(show)
    }
    
    /// shows or hides the close button (back caret)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseButton(_ show: Bool) {
        editorView.showCloseButton(show)
    }
    
    /// shows or hides the filter selection circle
    ///
    /// - Parameter show: true to show, false to hide
    func showSelectionCircle(_ show: Bool) {
        editorView.showSelectionCircle(show)
    }
}
