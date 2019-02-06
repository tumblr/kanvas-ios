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
    func didDropToDelete()
    
    /// Function called when the user pans to zoom on the capture button
    ///
    /// - Parameter
    ///     - mode: active mode when panning ocurred
    ///     - currentPoint: location of finger on the screen
    ///     - gesture: the long press gesture recognizer that performs the zoom action
    func didPanForZoom(_ mode: CameraMode, _ currentPoint: CGPoint, _ gesture: UILongPressGestureRecognizer)
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
    }

    /// shows the camera mode button
    func showModeButton() {
        modeView.showModeButton(true)
    }

    /// hides the camera mode button
    func hideModeButton() {
        modeView.showModeButton(false)
    }
    
    /// shows the trash icon
    func showTrashView(_ show: Bool) {
        modeView.showTrashView(show)
    }
    
}

extension ModeSelectorAndShootController: ModeSelectorAndShootViewDelegate {

    // MARK: - ModeButtonViewDelegate
    func modeButtonViewDidTap() {
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
            delegate?.didTapForMode(mode)
        }
    }

    func shootButtonViewDidStartLongPress() {
        if let mode = currentMode {
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
        delegate?.didDropToDelete()
    }
    
    func shootButtonDidZoom(currentPoint: CGPoint, gesture: UILongPressGestureRecognizer) {
        if let mode = currentMode {
            delegate?.didPanForZoom(mode, currentPoint, gesture)
        }
    }
}
