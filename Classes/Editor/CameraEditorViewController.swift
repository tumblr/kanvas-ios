//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for camera editor controller methods

protocol CameraEditorControllerDelegate: class {
    /// callback when finished exporting video clips.
    func didFinishExportingVideo(url: URL?)
    
    /// callback when finished exporting image
    func didFinishExportingImage(image: UIImage?)
    
    /// callback when dismissing controller without exporting
    func dismissButtonPressed()
}


/// A view controller to edit the segments
final class CameraEditorViewController: UIViewController, CameraEditorViewDelegate, EditionMenuCollectionControllerDelegate, FilterSmallCollectionControllerDelegate {
    
    private lazy var cameraEditorView: CameraEditorView = {
        let editorView = CameraEditorView()
        editorView.delegate = self
        return editorView
    }()
    
    private lazy var collectionController: EditionMenuCollectionController = {
        let controller = EditionMenuCollectionController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    
    private lazy var filterCollectionController: FilterSmallCollectionController = {
        let controller = FilterSmallCollectionController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    
    private lazy var loadingView: LoadingIndicatorView = LoadingIndicatorView()
    
    private let settings: CameraSettings
    private let segments: [CameraSegment]
    private let assetsHandler: AssetsHandlerType
    private let cameraMode: CameraMode?
    
    private var currentSegmentIndex: Int = 0
    private var timer: Timer = Timer()
    
    private var firstPlayer: AVPlayer = AVPlayer()
    private var secondPlayer: AVPlayer = AVPlayer()
    private var currentPlayer: AVPlayer
    
    weak var delegate: CameraEditorControllerDelegate?
    
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
        self.currentPlayer = firstPlayer
        
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
        resumePlayback()
    }
    
    @objc private func appWillResignActive() {
        timer.invalidate()
        currentPlayer.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        restartPlayback()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        cameraEditorView.add(into: view)
        cameraEditorView.setFirstPlayer(player: firstPlayer)
        cameraEditorView.setSecondPlayer(player: secondPlayer)
        
        load(childViewController: collectionController, into: cameraEditorView.collectionContainer)
        load(childViewController: filterCollectionController, into: cameraEditorView.filterCollectionContainer)
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - playback methods
    
    private func restartPlayback() {
        currentPlayer.pause()
        timer.invalidate()
        currentSegmentIndex = 0
        if let firstSegment = segments.first {
            playSegment(segment: firstSegment)
        }
    }
    
    private func resumePlayback() {
        guard segments.count > currentSegmentIndex else {
            return
        }
        let segment = segments[currentSegmentIndex]
        if let image = segment.image {
            playImage(image: image)
        }
        else if segment.videoURL != nil {
            currentPlayer.play()
        }
    }
    
    private func playSegment(segment: CameraSegment) {
        if let image = segment.image {
            playImage(image: image)
        }
        else if let url = segment.videoURL {
            playVideo(url: url)
        }
        queueNextSegment()
    }
    
    private func playImage(image: UIImage) {
        cameraEditorView.setImage(image: image)
        let displayTime = timeIntervalForImageSegments(segments)
        timer = Timer.scheduledTimer(withTimeInterval: displayTime, repeats: false, block: { [weak self] _ in
            self?.playNextSegment()
        })
    }
    
    private func timeIntervalForImageSegments(_ segments: [CameraSegment]) -> TimeInterval {
        for segment in segments {
            if segment.image == nil {
                return KanvasCameraTimes.stopMotionFrameTimeInterval
            }
        }
        return CMTimeGetSeconds(CMTimeMake(value: KanvasCameraTimes.onlyImagesFrameDuration, timescale: KanvasCameraTimes.stopMotionFrameTimescale))
    }
    
    private func playVideo(url: URL) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        if currentPlayer == firstPlayer {
            currentPlayer = secondPlayer
            cameraEditorView.showSecondPlayer()
        }
        else {
            currentPlayer = firstPlayer
            cameraEditorView.showFirstPlayer()
        }
        
        if currentPlayer.currentItem == nil {
            currentPlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
        currentPlayer.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playNextSegment), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc private func queueNextSegment() {
        let nextSegmentIndex = (currentSegmentIndex + 1) % segments.count
        guard nextSegmentIndex < segments.count else { return }
        let nextSegment = segments[nextSegmentIndex]
        var playerItem: AVPlayerItem? = nil
        if let url = nextSegment.videoURL, nextSegment.image == nil {
            playerItem = AVPlayerItem(url: url)
        }
        if currentPlayer == firstPlayer {
            secondPlayer.replaceCurrentItem(with: playerItem)
        }
        else if currentPlayer == secondPlayer {
            firstPlayer.replaceCurrentItem(with: playerItem)
        }
    }
    
    @objc private func playNextSegment() {
        currentPlayer.pause()
        currentPlayer.seek(to: CMTime.zero)
        currentSegmentIndex = (currentSegmentIndex + 1) % segments.count
        guard currentSegmentIndex < segments.count else { return }
        playSegment(segment: segments[currentSegmentIndex])
    }
    
    private func stopPlayback() {
        timer.invalidate()
        currentPlayer.pause()
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
        stopPlayback()
        showLoading()
        if segments.count == 1, let firstSegment = segments.first, let image = firstSegment.image {
            // If the camera mode is .stopMotion and the `exportStopMotionPhotoAsVideo` is true,
            // then single photos from that mode should still export as video.
            if let cameraMode = cameraMode, cameraMode == .stopMotion && settings.exportStopMotionPhotoAsVideo, let videoURL = firstSegment.videoURL {
                performUIUpdate {
                    self.delegate?.didFinishExportingVideo(url: videoURL)
                    self.hideLoading()
                }
            }
            else {
                performUIUpdate {
                    self.delegate?.didFinishExportingImage(image: image)
                    self.hideLoading()
                }
            }
        }
        else {
            createFinalContent()
        }
    }
    
    private func createFinalContent() {
        assetsHandler.mergeAssets(segments: segments, completion: { url in
            performUIUpdate {
                if let url = url {
                    self.delegate?.didFinishExportingVideo(url: url)
                    self.hideLoading()
                }
                else {
                    self.hideLoading()
                    // TODO: Localize strings
                    let viewModel = ModalViewModel(text: "There was an issue loading your post...",
                                                   confirmTitle: "Try again",
                                                   confirmCallback: {
                                                    self.showLoading()
                                                    self.createFinalContent()
                    },
                                                   cancelTitle: "Cancel",
                                                   cancelCallback: { [unowned self] in self.delegate?.didFinishExportingVideo(url: url) },
                                                   buttonsLayout: .oneBelowTheOther)
                    let controller = ModalController(viewModel: viewModel)
                    self.present(controller, animated: true, completion: .none)
                }
            }
        })
    }
    
    func closeButtonPressed() {
        stopPlayback()
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
        switch editionOption.type {
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
    
    // MARK: - FilterSmallCollectionControllerDelegate
    
    func didSelectFilter(_ filterItem: FilterItem) {
        
    }
    
    // MARK: - Public interface
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        cameraEditorView.showConfirmButton(show)
    }
    
    /// shows or hides the button to close a menu (checkmark)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseMenuButton(_ show: Bool) {
        cameraEditorView.showCloseMenuButton(show)
    }
    
    /// shows or hides the close button (back caret)
    ///
    /// - Parameter show: true to show, false to hide
    func showCloseButton(_ show: Bool) {
        cameraEditorView.showCloseButton(show)
    }
    
    /// shows or hides the filter selection circle
    ///
    /// - Parameter show: true to show, false to hide
    func showSelectionCircle(_ show: Bool) {
        cameraEditorView.showSelectionCircle(show)
    }
}
