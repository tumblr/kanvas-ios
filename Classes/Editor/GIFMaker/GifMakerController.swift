//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for editing GIFs
protocol GifMakerControllerDelegate: AnyObject {
    
    /// Called after the confirm button is tapped
    func didConfirmGif()

    /// Called after the revert button is tapped
    func didRevertGif()
    
    /// Called after a trimming movement starts
    func didStartTrimming()
    
    /// Called after the trim range changes
    ///
    /// - Parameters:
    ///  - startingPercentage: trimming starting moment expressed as a percentage.
    ///  - endingPercentage: trimming starting moment expressed as a percentage.
    func didTrim(from startingPercentage: CGFloat?, to endingPercentage: CGFloat?)
    
    /// Called after a trimming movement ends
    ///
    /// - Parameters:
    ///  - startingPercentage: trimming starting moment expressed as a percentage.
    ///  - endingPercentage: trimming starting moment expressed as a percentage.
    func didEndTrimming(from startingPercentage: CGFloat, to endingPercentage: CGFloat)
    
    /// Obtains the full media duration.
    func getMediaDuration() -> TimeInterval?
    
    /// Obtains a thumbnail for the background of the trimming tool
    ///
    /// - Parameter timestamp: the time of the requested image.
    func getThumbnail(at timestamp: TimeInterval) -> UIImage?
    
    /// Called when a new speed is selected.
    ///
    /// - Parameter speed: the selected speed.
    func didSelectSpeed(_ speed: Float)
    
    /// Called when a playback option is selected.
    ///
    /// - Parameter option: the selected option.
    func didSelectPlayback(_ option: PlaybackOption)

    func didOpenTrim()

    func didOpenSpeed()

    func startLocation(from index: Int) -> CGFloat?

    func endLocation(from index: Int) -> CGFloat?
}

/// A view controller that contains the GIF maker menu
final class GifMakerController: UIViewController, GifMakerViewDelegate, TrimControllerDelegate, SpeedControllerDelegate, OptionSelectorControllerDelegate {
    
    weak var delegate: GifMakerControllerDelegate?
        
    private lazy var gifMakerView: GifMakerView = {
        let view = GifMakerView()
        view.delegate = self
        return view
    }()
    
    private lazy var trimController: TrimController = {
        let controller = TrimController()
        controller.delegate = self
        return controller
    }()

    private lazy var speedController: SpeedController = {
        let controller = SpeedController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var playbackController: OptionSelectorController = {
        let options: [PlaybackOption] = [.loop, .rebound, .reverse]
        let controller = OptionSelectorController(options: options)
        controller.delegate = self
        return controller
    }()
    
    /// Confirm button location expressed in screen coordinates
    var confirmButtonLocation: CGPoint {
        return gifMakerView.confirmButtonLocation
    }
    
    private var trimEnabled: Bool {
        willSet {
            gifMakerView.changeTrimButton(newValue)
            trimController.showView(newValue)
        }
    }
    
    private var speedEnabled: Bool {
        willSet {
            gifMakerView.changeSpeedButton(newValue)
            speedController.showView(newValue)
        }
    }
    
    // MARK: - Initializers
    
    init() {
        trimEnabled = false
        speedEnabled = false
        super.init(nibName: .none, bundle: .none)
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func loadView() {
        view = gifMakerView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        load(childViewController: trimController, into: gifMakerView.trimMenuContainer)
        load(childViewController: speedController, into: gifMakerView.speedMenuContainer)
        load(childViewController: playbackController, into: gifMakerView.playbackMenuContainer)
    }
    
    // MARK: - Layout
    
    private func setUpView() {
        gifMakerView.alpha = 0
    }
    
    // MARK: - GifMakerViewDelegate
    
    func didTapConfirmButton() {
        delegate?.didConfirmGif()
    }
    
    func didTapTrimButton() {
        speedEnabled = false
        trimEnabled.toggle()
        if trimEnabled {
            delegate?.didOpenTrim()
        }
    }
    
    func didTapSpeedButton() {
        trimEnabled = false
        speedEnabled.toggle()
        if speedEnabled {
            delegate?.didOpenSpeed()
        }
    }

    func didTapRevertButton() {
        delegate?.didRevertGif()
    }
    
    // MARK: - TrimControllerDelegate
    
    func didStartTrimming() {
        delegate?.didStartTrimming()
    }
    
    func didTrim(from startingPercentage: CGFloat?, to endingPercentage: CGFloat?) {
        delegate?.didTrim(from: startingPercentage, to: endingPercentage)
    }
    
    func didEndTrimming(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        delegate?.didEndTrimming(from: startingPercentage, to: endingPercentage)
    }
    
    func getMediaDuration() -> TimeInterval? {
        return delegate?.getMediaDuration()
    }
    
    func getThumbnail(at timestamp: TimeInterval) -> UIImage? {
        return delegate?.getThumbnail(at: timestamp)
    }
    
    // MARK: - SpeedControllerDelegate
    
    func didSelectSpeed(_ speed: Float) {
        delegate?.didSelectSpeed(speed)
    }
    
    // MARK: - OptionSelectorControllerDelegate
    
    func didSelect(option: OptionSelectorItem) {
        guard let playbackOption = option as? PlaybackOption else { return }
        delegate?.didSelectPlayback(playbackOption)
    }
    
    // MARK: - Public interface
    
    /// shows or hides the GIF maker menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        gifMakerView.showView(show, completion: { [weak self] _ in
            self?.trimEnabled = show
            self?.speedEnabled = false
        })
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        gifMakerView.showConfirmButton(show)
    }

    func toggleRevertButton(_ show: Bool) {
        gifMakerView.toggleRevertButton(show)
    }

    func configure(settings: GIFMakerSettings?, animated: Bool) {
        guard let settings = settings else { return }
        playbackController.select(option: settings.playbackMode, animated: animated)
        speedController.select(speed: settings.rate)
        if let start = delegate?.startLocation(from: settings.startIndex),
            let end = delegate?.endLocation(from: settings.endIndex) {
            trimController.set(start: start, end: end)
        }
    }
}
