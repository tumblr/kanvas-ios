//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

private struct ModeSelectorAndShootViewConstants {
    static let tooltipTopMargin: CGFloat = 13.5
    static let tooltipArrowHeight: CGFloat = 7
    static let tooltipArrowWidth: CGFloat = 16
    static let tooltipBubbleWidth: CGFloat = 18
    static let tooltipBubbleHeight: CGFloat = 12
    static let tooltipCornerRadius: CGFloat = 6
    static let tooltipTextFont: UIFont = .favoritTumblr85(fontSize: 15)
    static let selectorYCenterMargin: CGFloat = 49
    static let shootButtonSize: CGFloat = ShootButtonView.buttonMaximumWidth
    static let shootButtonBottomMargin: CGFloat = 48
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
    private var tooltip: EasyTipView?

    /// Initializer for the mode selector view
    ///
    /// - Parameter settings: CameraSettings to determine the default and available modes
    init(settings: CameraSettings) {
        modeSelectorButton = ModeButtonView()
        shootButton = ShootButtonView(baseColor: KanvasCameraColors.shootButtonInactiveColor,
                                      activeColor: KanvasCameraColors.shootButtonActiveColor)
        self.settings = settings

        super.init(frame: .zero)
        backgroundColor = .clear
        tooltip = createTooltip()
        
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
    
    /// shows the tooltip below the mode selector
    func showTooltip() {
        tooltip?.show(animated: true, forView: modeSelectorButton, withinSuperview: self)
    }
    
    /// hides the tooltip below the mode selector
    func dismissTooltip() {
        tooltip?.dismiss()
    }
    
    // MARK: - UI Layout

    private func createTooltip() -> EasyTipView {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.foregroundColor = .white
        preferences.drawing.backgroundColorCollection = [.tumblrBrightBlue, .tumblrBrightPurple, .tumblrBrightPink]
        preferences.drawing.arrowPosition = .top
        preferences.drawing.arrowWidth = ModeSelectorAndShootViewConstants.tooltipArrowWidth
        preferences.drawing.arrowHeight = ModeSelectorAndShootViewConstants.tooltipArrowHeight
        preferences.drawing.cornerRadius = ModeSelectorAndShootViewConstants.tooltipCornerRadius
        preferences.drawing.font = ModeSelectorAndShootViewConstants.tooltipTextFont
        preferences.positioning.textHInset = ModeSelectorAndShootViewConstants.tooltipBubbleWidth
        preferences.positioning.textVInset = ModeSelectorAndShootViewConstants.tooltipBubbleHeight
        preferences.positioning.margin = ModeSelectorAndShootViewConstants.tooltipTopMargin
        let text = NSLocalizedString("Tap to switch modes", comment: "Welcome tooltip for the camera")
        return EasyTipView(text: text, preferences: preferences, delegate: nil)
    }
    
    private func setUpButtons() {
        setUpModeSelector()
        setUpShootButton()
    }

    private func setUpModeSelector() {
        modeSelectorButton.accessibilityIdentifier = "Mode Options Selector Button"
        
        addSubview(modeSelectorButton)
        modeSelectorButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modeSelectorButton.centerYAnchor.constraint(equalTo: safeLayoutGuide.topAnchor, constant: ModeSelectorAndShootViewConstants.selectorYCenterMargin),
            modeSelectorButton.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
        ])
    }

    private func setUpShootButton() {
        shootButton.accessibilityIdentifier = "Shoot Button"

        addSubview(shootButton)
        shootButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shootButton.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -ModeSelectorAndShootViewConstants.shootButtonBottomMargin),
            shootButton.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
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
