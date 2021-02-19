//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for camera preview controller methods

protocol CameraPreviewControllerDelegate: class {
    /// callback when finished exporting video clips.
    func didFinishExportingVideo(url: URL?)

    /// callback when finished exporting image
    func didFinishExportingImage(image: UIImage?)

    /// callback when finished exporting frames
    func didFinishExportingFrames(url: URL?)

    /// callback when dismissing controller without exporting
    func dismissButtonPressed()
}

/// A view controller to preview the segments sequentially
/// There are two AVPlayers to reduce loading times and the black screen when replacing player items

final class CameraPreviewViewController: UIViewController, MediaPlayerController {

    private lazy var cameraPreviewView: CameraPreviewView = {
        let previewView = CameraPreviewView()
        previewView.delegate = self
        return previewView
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

    weak var delegate: CameraPreviewControllerDelegate?

    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    /// The designated initializer for the preview controller
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
        cameraPreviewView.add(into: view)
        cameraPreviewView.setFirstPlayer(player: firstPlayer)
        cameraPreviewView.setSecondPlayer(player: secondPlayer)
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
            playImage(image: image, duration: segment.timeInterval)
        }
        else if segment.videoURL != nil {
            currentPlayer.play()
        }
    }

    private func playSegment(segment: CameraSegment) {
        if let image = segment.image {
            playImage(image: image, duration: segment.timeInterval)
        }
        else if let url = segment.videoURL {
            playVideo(url: url)
        }
        queueNextSegment()
    }

    private func playImage(image: UIImage, duration: TimeInterval?) {
        cameraPreviewView.setImage(image: image)
        let displayTime = duration ?? CameraPreviewViewController.defaultTimeIntervalForImageSegments(segments)
        timer = Timer.scheduledTimer(withTimeInterval: displayTime, repeats: false, block: { [weak self] _ in
            self?.playNextSegment()
        })
    }
    
    private static func defaultTimeIntervalForImageSegments(_ segments: [CameraSegment]) -> TimeInterval {
        CameraSegment.defaultTimeInterval(segments: segments)
    }

    private func playVideo(url: URL) {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        if currentPlayer == firstPlayer {
            currentPlayer = secondPlayer
            cameraPreviewView.showSecondPlayer()
        }
        else {
            currentPlayer = firstPlayer
            cameraPreviewView.showFirstPlayer()
        }

        if currentPlayer.currentItem == nil {
            currentPlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
        currentPlayer.play()

        NotificationCenter.default.addObserver(self, selector: #selector(playNextSegment), name: .AVPlayerItemDidPlayToEndTime, object: nil)
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
    
    // MARK: - MediaPlayerController
    
    func onPostingOptionsDismissed() {
        // Does nothing
    }
    
    func onQuickPostButtonSubmitted() {
        // Does nothing
    }
    
    func onQuickPostOptionsShown(visible: Bool, hintText: String?, view: UIView) {
        // Does nothing
    }
    
    func onQuickPostOptionsSelected(selected: Bool, hintText: String?, view: UIView) {
        // Does nothing
    }
}

// MARK: - CameraPreviewView

extension CameraPreviewViewController: CameraPreviewViewDelegate {
    func confirmButtonPressed() {
        stopPlayback()
        showLoading()
        if segments.count == 1, let firstSegment = segments.first {
            switch firstSegment {
                case .image(let image, let videoURL, _, _):
                    // If the camera mode is .stopMotion, or .stitch (.video) and the `exportStopMotionPhotoAsVideo` is true,
                    // then single photos from that mode should still export as video.
                    if let cameraMode = cameraMode, cameraMode.group == .video && cameraMode != .normal && settings.exportStopMotionPhotoAsVideo {
                        performUIUpdate {
                            self.delegate?.didFinishExportingVideo(url: videoURL)
                            self.hideLoading()
                        }
                    } else {
                        performUIUpdate {
                            self.delegate?.didFinishExportingImage(image: image)
                            self.hideLoading()
                        }
                    }
                case .video(let videoURL, _):
                    // If the camera mode is .stopMotion, .normal or .stitch (.video) and the `exportStopMotionPhotoAsVideo` is true,
                    // then single photos from that mode should still export as video.
                    if settings.features.gifs,
                       let group = cameraMode?.group, group == .gif {
                        performUIUpdate {
                            self.delegate?.didFinishExportingVideo(url: videoURL)
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
        assetsHandler.mergeAssets(segments: segments, withAudio: true, completion: { url, _  in
            performUIUpdate {
                if let url = url {
                    self.delegate?.didFinishExportingVideo(url: url)
                    self.hideLoading()
                }
                else {
                    self.hideLoading()
                    let alertController = UIAlertController(title: nil, message: NSLocalizedString("SomethingGoofedTitle", comment: "Alert controller message"), preferredStyle: .alert)
                    
                    let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel alert controller"), style: .cancel) { [weak self] _ in
                        self?.delegate?.didFinishExportingVideo(url: url)
                    }
                    
                    let tryAgainButton = UIAlertAction(title: NSLocalizedString("Try again", comment: "Try creating final content again"), style: .default) { [weak self] _ in
                        self?.showLoading()
                        self?.createFinalContent()
                    }
                    
                    alertController.addAction(tryAgainButton)
                    alertController.addAction(cancelButton)
                    
                    self.present(alertController, animated: true, completion: .none)
                }
            }
        })
    }

    func closeButtonPressed() {
        stopPlayback()
        delegate?.dismissButtonPressed()
    }
}
