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
}

/// Controller that handles interaction between the mode selector and the capture button
final class ModeSelectorAndShootController: UIViewController {

    private let settings: CameraSettings
    lazy var _view: ModeSelectorAndShootView = {
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
        view = _view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let mode = modesQueue.first {
            setMode(mode, from: nil)
        }
    }

    /// shows the camera mode button
    func showModeButton() {
        _view.showModeButton(true)
    }

    /// hides the camera mode button
    func hideModeButton() {
        _view.showModeButton(false)
    }

}

extension ModeSelectorAndShootController: ModeSelectorAndShootViewDelegate {

    // MARK: - ModeButtonViewDelegate
    func modeButtonViewDidTap() {
        let oldMode = modesQueue.rotateOnce()
        if let newMode = modesQueue.first {
            setMode(newMode, from: oldMode)
        }
    }

    func setMode(_ newMode: CameraMode, from oldMode: CameraMode?) {
        _view.setUpMode(newMode)
        delegate?.didOpenMode(newMode, andClosed: oldMode)

    }

    // MARK: - ShootButtonViewDelegate
    func shootButtonViewDidTap() {
        if let mode = modesQueue.first {
            delegate?.didTapForMode(mode)
        }
    }

    func shootButtonViewDidStartLongPress() {
        if let mode = modesQueue.first {
            delegate?.didStartPressingForMode(mode)
        }
    }

    func shootButtonViewDidEndLongPress() {
        if let mode = modesQueue.first {
            delegate?.didEndPressingForMode(mode)
        }
    }

    func shootButtonReachedMaximumTime() {
        if let mode = modesQueue.first {
            delegate?.didEndPressingForMode(mode)
        }
    }

}
