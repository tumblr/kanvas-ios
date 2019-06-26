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
    func didFinishExportingVideo(url: URL?)
    
    /// callback when finished exporting image
    func didFinishExportingImage(image: UIImage?)
    
    /// callback when dismissing controller without exporting
    func dismissButtonPressed()
}


/// A view controller to edit the segments
final class EditorViewController: UIViewController, EditorViewDelegate, EditionMenuCollectionControllerDelegate, EditorFilterCollectionControllerDelegate {
    
    private lazy var editorView: EditorView = {
        let editorView = EditorView()
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
        self.player = GLPlayer()
        
        super.init(nibName: .none, bundle: .none)
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    func confirmButtonPressed() {
        player.stop()
        showLoading()
        if segments.count == 1, let firstSegment = segments.first, let image = firstSegment.image {
            // If the camera mode is .stopMotion and the `exportStopMotionPhotoAsVideo` is true,
            // then single photos from that mode should still export as video.
            let exporter = GLMediaExporter(filterType: filterType)
            if let cameraMode = cameraMode, cameraMode == .stopMotion && settings.exportStopMotionPhotoAsVideo, let videoURL = firstSegment.videoURL {
                exporter.export(video: videoURL) { exportedVideoURL in
                    performUIUpdate {
                        self.delegate?.didFinishExportingVideo(url: exportedVideoURL)
                        self.hideLoading()
                    }
                }
            }
            else {
                exporter.export(image: image) { exportedImage in
                    performUIUpdate {
                        self.delegate?.didFinishExportingImage(image: exportedImage)
                        self.hideLoading()
                    }
                }
            }
        }
        else {
            createFinalContent()
        }
    }
    
    private func createFinalContent() {
        assetsHandler.mergeAssets(segments: segments, completion: { url in
            guard let url = url else {
                self.finishCreatingFinalContent(url: nil)
                return
            }
            let exporter = GLMediaExporter(filterType: self.filterType)
            exporter.export(video: url) { newURL in
                self.finishCreatingFinalContent(url: newURL)
            }
        })
    }

    private func finishCreatingFinalContent(url: URL?) {
        performUIUpdate {
            if let url = url {
                self.delegate?.didFinishExportingVideo(url: url)
                self.hideLoading()
            }
            else {
                self.hideLoading()
                let alertController = UIAlertController(title: nil, message: NSLocalizedString("SomethingGoofedTitle", comment: "Alert controller message"), preferredStyle: .alert)

                let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel alert controller"), style: .cancel) { [unowned self] _ in
                    self.delegate?.didFinishExportingVideo(url: url)
                }

                let tryAgainButton = UIAlertAction(title: NSLocalizedString("Try again", comment: "Try creating final content again"), style: .default) { [unowned self] _ in
                    self.showLoading()
                    self.createFinalContent()
                }

                alertController.addAction(tryAgainButton)
                alertController.addAction(cancelButton)

                self.present(alertController, animated: true, completion: .none)
            }
        }
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
