//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Protocol for handling mode selector and capture button events
protocol ModeSelectorAndShootControllerDelegate: class {
    /// Function called when a mode was selected
    ///
    /// - Parameter mode: selected mode
    /// - Parameter oldMode: the mode that was closed
    /// (if there was one opened, which will not happen the first time)
    func didOpenMode(_ mode: CameraMode, andClosed oldMode: CameraMode?)
    /// Function called when the user taps on the capture button
    ///
    /// - Parameter mode: active mode when tapping occured
    func didTapForMode(_ mode: CameraMode)
    /// Function called when the user starts a long press on the capture button
    ///
    /// - Parameter mode: active mode when long press started
    func didStartPressingForMode(_ mode: CameraMode)
    /// Function called when the user starts a long press on the capture button
    ///
    /// - Parameter mode: active mode when long press ended
    func didEndPressingForMode(_ mode: CameraMode)
    /// Function called when a clip was dropped on the capture button to be deleted
    func didDropToDelete(_ mode: CameraMode)
    
    /// Function called when the user pans to zoom on the capture button
    ///
    /// - Parameter
    ///     - mode: active mode when panning ocurred
    ///     - currentPoint: location of finger on the screen
    ///     - gesture: the long press gesture recognizer that performs the zoom action
    func didPanForZoom(_ mode: CameraMode, _ currentPoint: CGPoint, _ gesture: UILongPressGestureRecognizer)
    
    /// Function called when the welcome tooltip is dismissed
    func didDismissWelcomeTooltip()

    func didTapMediaPickerButton()

    func provideMediaPickerThumbnail(completion: @escaping (UIImage?) -> Void)
}

/// Controller that handles interaction between the mode selector and the capture button
final class ModeSelectorAndShootController: UIViewController {

    private let settings: CameraSettings
    lazy var modeView: ModeSelectorAndShootView = {
        let view = ModeSelectorAndShootView(settings: self.settings)
        view.delegate = self
        return view
    }()

    weak var delegate: ModeSelectorAndShootControllerDelegate?

    private lazy var modesQueue: Queue<CameraMode> = {
        var queue = Queue(elements: self.settings.orderedEnabledModes)
        // Start in the default mode but maintain order
        while queue.first != self.settings.initialMode {
            let _ = queue.rotateOnce()
        }
        return queue
    }()
    
    private var currentMode: CameraMode? {
        return modesQueue.first
    }
    
    /// Initializer with CameraSettings
    ///
    /// - Parameter settings: CameraSettings to determine the available modes and default images
    init(settings: CameraSettings) {
        self.settings = settings
        super.init(nibName: .none, bundle: .none)
    }

    @available(*, unavailable, message: "use init(settings:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    // MARK: - View Life Cycle
    override func loadView() {
        view = modeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mode = currentMode {
            setMode(mode, from: nil)
        }
        if modesQueue.count == 1 {
            hideModeButton()
        }
        loadMediaPickerThumbnail()
    }
    
    // MARK: - Public interface
    
    /// generates a tap gesture on the shutter button
    ///
    /// - Parameter recognizer: the tap gesture recognizer
    func tapShootButton(recognizer: UITapGestureRecognizer) {
        modeView.tapShootButton(recognizer: recognizer)
    }
    
    /// generates a longpress gesture on the shutter button
    ///
    /// - Parameter recognizer: the longpress gesture recognizer
    func longPressShootButton(recognizer: UILongPressGestureRecognizer) {
        modeView.longPressShootButton(recognizer: recognizer)
    }
    
    /// enables or disables the user interation on the shutter button
    ///
    /// - Parameter enabled: true to enable, false to disable
    func enableShootButtonUserInteraction(_ enabled: Bool) {
        modeView.enableShootButtonUserInteraction(enabled)
    }
    
    /// shows the camera mode button
    func showModeButton() {
        modeView.showModeButton(true)
    }

    /// hides the camera mode button
    func hideModeButton() {
        modeView.showModeButton(false)
        dismissTooltip()
    }
    
    /// shows the tooltip below the mode selector
    func showTooltip() {
        modeView.showTooltip()
    }
    
    /// dismisses the tooltip below the mode selector
    func dismissTooltip() {
        modeView.dismissTooltip()
    }
    
    /// shows the inner circle used for the press effect
    func showPressInnerCircle() {
        modeView.showPressInnerCircle(true)
    }
    
    /// hides the inner circle image for the press effect
    func hidePressInnerCircle() {
        modeView.showPressInnerCircle(false)
    }
    
    /// shows the outer translucent circle used for the press effect
    func showPressBackgroundCircle() {
        modeView.showPressBackgroundCircle(true)
    }
    
    /// hides the outer translucent circle used for the press effect
    func hidePressBackgroundCircle() {
        modeView.showPressBackgroundCircle(false)
    }
    
    /// shows the border of the shutter button
    func showBorderView() {
        modeView.showBorderView(true)
    }
    
    /// hides the border of the shutter button
    func hideBorderView() {
        modeView.showBorderView(false)
    }

    /// shows the trash icon closed
    func showTrashClosed(_ show: Bool) {
        modeView.showTrashClosed(show)
    }

    /// shows the trash icon opened
    func showTrashOpened(_ show: Bool) {
        modeView.showTrashOpened(show)
    }

    func toggleMediaPickerButton(_ visible: Bool) {
        modeView.toggleMediaPickerButton(visible)
    }

    func loadMediaPickerThumbnail() {
        delegate?.provideMediaPickerThumbnail { image in
            guard let image = image else {
                return
            }
            self.setMediaPickerButtonThumbnail(image)
        }
    }

    func setMediaPickerButtonThumbnail(_ image: UIImage) {
        modeView.setMediaPickerButtonThumbnail(image)
    }
}

extension ModeSelectorAndShootController: ModeSelectorAndShootViewDelegate {
    
    // MARK: - ModeSelectorAndShootViewDelegate
    func didDismissWelcomeTooltip() {
        delegate?.didDismissWelcomeTooltip()
    }
    
    // MARK: - ModeButtonViewDelegate
    func modeButtonViewDidTap() {
        dismissTooltip()
        let oldMode = modesQueue.rotateOnce()
        if let newMode = currentMode {
            setMode(newMode, from: oldMode)
        }
    }

    func setMode(_ newMode: CameraMode, from oldMode: CameraMode?) {
        modeView.setUpMode(newMode)
        delegate?.didOpenMode(newMode, andClosed: oldMode)
    }

    // MARK: - ShootButtonViewDelegate
    func shootButtonViewDidTap() {
        if let mode = currentMode {
            dismissTooltip()
            delegate?.didTapForMode(mode)
        }
    }

    func shootButtonViewDidStartLongPress() {
        if let mode = currentMode {
            dismissTooltip()
            delegate?.didStartPressingForMode(mode)
        }
    }

    func shootButtonViewDidEndLongPress() {
        if let mode = currentMode {
            delegate?.didEndPressingForMode(mode)
        }
    }

    func shootButtonReachedMaximumTime() {
        if let mode = currentMode {
            delegate?.didEndPressingForMode(mode)
        }
    }
    
    func shootButtonDidReceiveDropInteraction() {
        if let mode = currentMode {
            delegate?.didDropToDelete(mode)
        }
    }
    
    func shootButtonDidZoom(currentPoint: CGPoint, gesture: UILongPressGestureRecognizer) {
        if let mode = currentMode {
            delegate?.didPanForZoom(mode, currentPoint, gesture)
        }
    }

    func mediaPickerButtonDidPress() {
        delegate?.didTapMediaPickerButton()
    }
}
