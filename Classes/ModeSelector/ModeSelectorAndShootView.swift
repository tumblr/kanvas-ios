//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

private struct ModeSelectorAndShootViewConstants {
    static let selectorYCenterMargin: CGFloat = (CameraConstants.optionButtonSize / 2)
    static let shootButtonSize: CGFloat = ShootButtonView.buttonMaximumWidth
    static let shootButtonBottomMargin: CGFloat = 4
    static var shootButtonTopMargin: CGFloat {
        return ModeSelectorAndShootViewConstants.shootButtonBottomMargin + ModeSelectorAndShootViewConstants.shootButtonSize
    }
}

/// Protocol to handle mode selector container and capture button user actions
protocol ModeSelectorAndShootViewDelegate: ShootButtonViewDelegate, ModeButtonViewDelegate { }

/// View that layouts mode selector container and capture button
/// Also communicates capture button interactions
final class ModeSelectorAndShootView: IgnoreTouchesView {

    /// exposed for other classes that need to know the sizing of the buttons
    static let shootButtonSize = ModeSelectorAndShootViewConstants.shootButtonSize
    static let shootButtonBottomMargin = ModeSelectorAndShootViewConstants.shootButtonBottomMargin
    static let shootButtonTopMargin = ModeSelectorAndShootViewConstants.shootButtonTopMargin

    weak var delegate: ModeSelectorAndShootViewDelegate? {
        didSet {
            shootButton.delegate = delegate
            modeSelectorButton.delegate = delegate
        }
    }

    private let settings: CameraSettings
    private let shootButton: ShootButtonView
    private let modeSelectorButton: ModeButtonView

    /// Initializer for the mode selector view
    ///
    /// - Parameter settings: CameraSettings to determine the default and available modes
    init(settings: CameraSettings) {
        modeSelectorButton = ModeButtonView()
        shootButton = ShootButtonView(baseColor: KanvasCameraColors.shootButtonInactiveColor, activeColor: KanvasCameraColors.shootButtonActiveColor)
        self.settings = settings

        super.init(frame: .zero)

        backgroundColor = .clear
        setUpButtons()
    }

    @available(*, unavailable, message: "use init(settings:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(settings:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// configures the UI to the correct mode
    ///
    /// - Parameter selectedMode: the mode to switch the UI to
    func setUpMode(_ selectedMode: CameraMode) {
        modeSelectorButton.setTitle(KanvasCameraStrings.name(for: selectedMode))
        shootButton.configureFor(trigger: triggerFor(selectedMode),
                                 image: KanvasCameraImages.image(for: selectedMode),
                                 timeLimit: KanvasCameraTimes.recordingTime(for: selectedMode))
    }

    /// show or hide the mode button with an animation
    ///
    /// - Parameter show: true to show, false to hide
    func showModeButton(_ show: Bool) {
        if show {
            showViews(shownViews: [modeSelectorButton], hiddenViews: [], animated: true)
        }
        else {
            showViews(shownViews: [], hiddenViews: [modeSelectorButton], animated: true)
        }
    }
    
    /// shows the trash icon
    func showTrashView(_ show: Bool) {
        shootButton.showTrashView(show)
    }

    // MARK: - UI Layout

    private func setUpButtons() {
        setUpModeSelector()
        setUpShootButton()
    }

    private func setUpModeSelector() {
        modeSelectorButton.accessibilityIdentifier = "Mode Options Selector Button"
        
        addSubview(modeSelectorButton)
        modeSelectorButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modeSelectorButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                                        constant: ModeSelectorAndShootViewConstants.selectorYCenterMargin),
            modeSelectorButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
        ])
    }

    private func setUpShootButton() {
        shootButton.accessibilityIdentifier = "Shoot Button"

        addSubview(shootButton)
        shootButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shootButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -ModeSelectorAndShootViewConstants.shootButtonBottomMargin),
            shootButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            shootButton.heightAnchor.constraint(equalTo: shootButton.widthAnchor),
            shootButton.widthAnchor.constraint(equalToConstant: ModeSelectorAndShootViewConstants.shootButtonSize)
        ])
    }

    // MARK: - Triggers by mode
    
    private func triggerFor(_ mode: CameraMode) -> CaptureTrigger {
        switch mode {
            case .photo: return .tap
            case .gif: return .tapAndHold
            case .stopMotion: return .tapAndHold
        }
    }
}
