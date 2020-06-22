//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for editing GIFs
protocol GifMakerControllerDelegate: class {
    
    /// Called after the confirm button is tapped
    func didConfirmGif()
    
    /// Called after a trimming movement starts
    func didStartTrimming()
    
    /// Called after the trim range changes
    ///
    /// - Parameters:
    ///  - startingPercentage: trimming starting moment expressed as a percentage.
    ///  - endingPercentage: trimming starting moment expressed as a percentage.
    func didTrim(from startingPercentage: CGFloat, to endingPercentage: CGFloat)
    
    /// Called after a trimming movement ends
    ///
    /// - Parameters:
    ///  - startingPercentage: trimming starting moment expressed as a percentage.
    ///  - endingPercentage: trimming starting moment expressed as a percentage.
    func didEndTrimming(from startingPercentage: CGFloat, to endingPercentage: CGFloat)
    
    
    /// Obtains a thumbnail for the background of the trimming tool
    ///
    /// - Parameter index: the index of the requested image.
    func getThumbnail(at index: Int) -> UIImage?
    
    /// Called when a new speed is selected.
    ///
    /// - Parameter speed: the selected speed.
    func didSelectSpeed(_ speed: Float)
    
    /// Called when a playback option is selected.
    ///
    /// - Parameter option: the selected option.
    func didSelectPlayback(_ option: PlaybackOption)
}

/// A view controller that contains the GIF maker menu
final class GifMakerController: UIViewController, GifMakerViewDelegate, TrimControllerDelegate, SpeedControllerDelegate, PlaybackControllerDelegate {
    
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
    
    private lazy var playbackController: PlaybackController = {
        let controller = PlaybackController()
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
    }
    
    func didTapSpeedButton() {
        trimEnabled = false
        speedEnabled.toggle()
    }
    
    // MARK: - TrimControllerDelegate
    
    func didStartTrimming() {
        delegate?.didStartTrimming()
    }
    
    func didTrim(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        delegate?.didTrim(from: startingPercentage, to: endingPercentage)
    }
    
    func didEndTrimming(from startingPercentage: CGFloat, to endingPercentage: CGFloat) {
        delegate?.didEndTrimming(from: startingPercentage, to: endingPercentage)
    }
    
    func getThumbnail(at index: Int) -> UIImage? {
        return delegate?.getThumbnail(at: index)
    }
    
    // MARK: - SpeedControllerDelegate
    
    func didSelectSpeed(_ speed: Float) {
        delegate?.didSelectSpeed(speed)
    }
    
    // MARK: - PlaybackControllerDelegate
    
    func didSelect(option: PlaybackOption) {
        delegate?.didSelectPlayback(option)
    }
    
    // MARK: - Public interface
    
    /// shows or hides the GIF maker menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        gifMakerView.showView(show, completion: { [weak self] _ in
            self?.trimEnabled = false
            self?.speedEnabled = false
        })
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        gifMakerView.showConfirmButton(show)
    }
    
    /// Sets the size of the thumbnail collection
    ///
    /// - Parameter count: the new size
    func setThumbnails(count: Int) {
        trimController.setThumbnails(count: count)
    }
}
