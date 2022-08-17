//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for closing the GIF maker
protocol GifMakerViewDelegate: AnyObject {
    
    /// Called when the confirm button is selected
    func didTapConfirmButton()
    
    /// Called when the trim button is selected
    func didTapTrimButton()
    
    /// Called when the speed tools button is selected
    func didTapSpeedButton()

    /// Called when the revert button is tapped
    func didTapRevertButton()
}

/// Constants for GifMakerView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    
    // General margins
    static let topMargin: CGFloat = 19.5
    static let bottomMargin: CGFloat = 16
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
    static let trimMenuMargin: CGFloat = 16
    static let speedMenuMargin: CGFloat = 34
    
    // Top options
    static let topButtonSize: CGFloat = KanvasEditorDesign.shared.topButtonSize
    static let topButtonInset: CGFloat = -10
    static let topButtonsInterspace: CGFloat = KanvasEditorDesign.shared.topButtonInterspace
    static let topButtonsCount: CGFloat = 3

    static let font = KanvasFonts.shared.gifMakerRevertButtonFont
    static let revertFontColor = UIColor(red: 1, green: 0.286, blue: 0.188, alpha: 1)
    static let revertBackgroundColor = UIColor.white
}

/// A UIView for the GIF maker view
final class GifMakerView: UIView {
    
    weak var delegate: GifMakerViewDelegate?
    
    private let confirmButton: UIButton
    private let trimButton: UIButton
    private let speedButton: UIButton
    private lazy var revertButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let topButtonsContainer: UIView
    let trimMenuContainer: IgnoreTouchesView
    let speedMenuContainer: IgnoreTouchesView
    let playbackMenuContainer: IgnoreTouchesView
    
    /// Confirm button location expressed in screen coordinates
    var confirmButtonLocation: CGPoint {
        return topButtonsContainer.convert(confirmButton.center, to: nil)
    }

    private var disposables: [NSKeyValueObservation] = []
    
    // MARK: - Initializers
    
    init() {
        confirmButton = ExtendedButton(inset: Constants.topButtonInset)
        trimButton = ExtendedButton(inset: Constants.topButtonInset)
        speedButton = ExtendedButton(inset: Constants.topButtonInset)
        topButtonsContainer = IgnoreTouchesView()
        trimMenuContainer = IgnoreTouchesView()
        speedMenuContainer = IgnoreTouchesView()
        playbackMenuContainer = IgnoreTouchesView()
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupViews() {
        setUpTopButtonsContainer()
        setUpConfirmButton()
        setUpTrimButton()
        setUpSpeedButton()
        setupRevertButton()
        setupTrimMenuContainer()
        setupSpeedMenuContainer()
        setupPlaybackMenuContainer()
    }
    
    /// Sets up the container for the top buttons
    private func setUpTopButtonsContainer() {
        topButtonsContainer.accessibilityIdentifier = "GIF Maker Top Buttons Container"
        topButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topButtonsContainer)
        
        let height = Constants.topButtonSize * Constants.topButtonsCount + Constants.topButtonsInterspace * (Constants.topButtonsCount - 1)
        NSLayoutConstraint.activate([
            topButtonsContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topMargin),
            topButtonsContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.rightMargin),
            topButtonsContainer.heightAnchor.constraint(equalToConstant: height),
            topButtonsContainer.widthAnchor.constraint(equalToConstant: Constants.topButtonSize)
        ])
    }
    
    /// Sets up the confirmation button with a check mark
    private func setUpConfirmButton() {
        confirmButton.accessibilityIdentifier = "GIF Maker Confirm Button"
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        topButtonsContainer.addSubview(confirmButton)
        
        let checkmark = KanvasEditorDesign.shared.checkmarkImage
        if KanvasEditorDesign.shared.isVerticalMenu {
            let backgroundImage = UIImage.circle(diameter: Constants.topButtonSize, color: KanvasColors.shared.primaryButtonBackgroundColor)
            confirmButton.setBackgroundImage(backgroundImage, for: .normal)
            confirmButton.setImage(checkmark, for: .normal)
        }
        else {
            confirmButton.setBackgroundImage(checkmark, for: .normal)
        }
        
        let index: CGFloat = 0
        let topOffset = (Constants.topButtonSize + Constants.topButtonsInterspace) * index
        NSLayoutConstraint.activate([
            confirmButton.centerXAnchor.constraint(equalTo: topButtonsContainer.centerXAnchor),
            confirmButton.topAnchor.constraint(equalTo: topButtonsContainer.topAnchor, constant: topOffset),
            confirmButton.heightAnchor.constraint(equalToConstant: Constants.topButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: Constants.topButtonSize)
        ])
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        confirmButton.alpha = 0
    }
    
    /// Sets up the trim button in the top options
    private func setUpTrimButton() {
        trimButton.accessibilityIdentifier = "GIF Maker Trim Button"
        trimButton.setBackgroundImage(KanvasImages.trimOff, for: .normal)
        trimButton.translatesAutoresizingMaskIntoConstraints = false
        topButtonsContainer.addSubview(trimButton)
        
        let index: CGFloat = 1
        let topOffset = (Constants.topButtonSize + Constants.topButtonsInterspace) * index
        NSLayoutConstraint.activate([
            trimButton.centerXAnchor.constraint(equalTo: topButtonsContainer.centerXAnchor ),
            trimButton.topAnchor.constraint(equalTo: topButtonsContainer.topAnchor, constant: topOffset),
            trimButton.heightAnchor.constraint(equalToConstant: Constants.topButtonSize),
            trimButton.widthAnchor.constraint(equalToConstant: Constants.topButtonSize)
        ])
        
        trimButton.addTarget(self, action: #selector(trimButtonTapped), for: .touchUpInside)
    }
    
    /// Sets up the speed tools button in the top options
    private func setUpSpeedButton() {
        speedButton.accessibilityIdentifier = "GIF Maker Speed Button"
        speedButton.setBackgroundImage(KanvasImages.speedOff, for: .normal)
        speedButton.translatesAutoresizingMaskIntoConstraints = false
        topButtonsContainer.addSubview(speedButton)
        
        let index: CGFloat = 2
        let topOffset = (Constants.topButtonSize + Constants.topButtonsInterspace) * index
        NSLayoutConstraint.activate([
            speedButton.centerXAnchor.constraint(equalTo: topButtonsContainer.centerXAnchor ),
            speedButton.topAnchor.constraint(equalTo: topButtonsContainer.topAnchor, constant: topOffset),
            speedButton.heightAnchor.constraint(equalToConstant: Constants.topButtonSize),
            speedButton.widthAnchor.constraint(equalToConstant: Constants.topButtonSize)
        ])
        
        speedButton.addTarget(self, action: #selector(speedButtonTapped), for: .touchUpInside)
    }

    private func setupRevertButton() {
        revertButton.accessibilityIdentifier = "GIF Maker Revert Button"

        revertButton.contentHorizontalAlignment = .center
        revertButton.backgroundColor = Constants.revertBackgroundColor
        revertButton.setTitle("Revert", for: .normal)
        revertButton.setTitleColor(Constants.revertFontColor, for: .normal)
        revertButton.titleLabel?.font = Constants.font
        revertButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        disposables.append(revertButton.observe(\.bounds) { object, _ in
            self.revertButton.layer.cornerRadius = self.revertButton.bounds.height / 2
        })

        revertButton.layer.backgroundColor = UIColor.white.cgColor
        revertButton.layer.borderColor = UIColor.white.cgColor
        revertButton.layer.borderWidth = 2
        revertButton.layer.masksToBounds = true
        revertButton.clipsToBounds = true

        revertButton.addTarget(self, action: #selector(revertButtonTapped), for: .touchUpInside)
        revertButton.addTarget(self, action: #selector(revertButtonStartTap), for: .touchDown)
        revertButton.addTarget(self, action: #selector(revertButtonStopTap), for: [.touchUpOutside, .touchUpInside, .touchCancel, .touchDragOutside, .touchDragExit])

        toggleRevertButton(false)

        addSubview(revertButton)

        revertButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            revertButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            revertButton.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor)
        ])
    }
    
    /// Sets up the container for the trim menu
    private func setupTrimMenuContainer() {
        trimMenuContainer.backgroundColor = .clear
        trimMenuContainer.accessibilityIdentifier = "GIF Maker Trim Menu Container"
        trimMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        trimMenuContainer.clipsToBounds = false
        addSubview(trimMenuContainer)
        
        let bottomMargin = Constants.bottomMargin + OptionSelectorView.height + Constants.trimMenuMargin
        NSLayoutConstraint.activate([
            trimMenuContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            trimMenuContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            trimMenuContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -bottomMargin),
            trimMenuContainer.heightAnchor.constraint(equalToConstant: TrimView.height),
        ])
    }
    
    /// Sets up the container for the speed tools menu
    private func setupSpeedMenuContainer() {
        speedMenuContainer.backgroundColor = .clear
        speedMenuContainer.accessibilityIdentifier = "GIF Maker Speed Menu Container"
        speedMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        speedMenuContainer.clipsToBounds = false
        addSubview(speedMenuContainer)
        
        let bottomMargin = Constants.bottomMargin + OptionSelectorView.height + Constants.speedMenuMargin
        NSLayoutConstraint.activate([
            speedMenuContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leftMargin),
            speedMenuContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.rightMargin),
            speedMenuContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -bottomMargin),
            speedMenuContainer.heightAnchor.constraint(equalToConstant: SpeedView.height),
        ])
    }
    
    /// Sets up the container for the playback menu
    private func setupPlaybackMenuContainer() {
        playbackMenuContainer.backgroundColor = .clear
        playbackMenuContainer.accessibilityIdentifier = "GIF Maker Playback Menu Container"
        playbackMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        playbackMenuContainer.clipsToBounds = false
        addSubview(playbackMenuContainer)
        
        NSLayoutConstraint.activate([
            playbackMenuContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leftMargin),
            playbackMenuContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.rightMargin),
            playbackMenuContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomMargin),
            playbackMenuContainer.heightAnchor.constraint(equalToConstant: OptionSelectorView.height),
        ])
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func confirmButtonTapped() {
        delegate?.didTapConfirmButton()
    }
    
    @objc private func trimButtonTapped() {
        delegate?.didTapTrimButton()
    }
    
    @objc private func speedButtonTapped() {
        delegate?.didTapSpeedButton()
    }

    @objc private func revertButtonTapped() {
        delegate?.didTapRevertButton()
    }

    @objc private func revertButtonStartTap() {
        revertButton.layer.backgroundColor = UIColor.clear.cgColor
    }

    @objc private func revertButtonStopTap() {
        revertButton.layer.backgroundColor = UIColor.white.cgColor
    }
    
    // MARK: - Public interface
    
    /// shows or hides the view
    ///
    /// - Parameters
    ///  - show: true to show, false to hide.
    ///  - completion: optional closure to execute after the animation.
    func showView(_ show: Bool, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: Constants.animationDuration, animations: { [weak self] in
            self?.alpha = show ? 1 : 0
        }, completion: completion)
    }
    
    
    /// Changes the trim button image with an animation
    ///
    /// - Parameter image: the new image for the button
    func changeTrimButton(_ enabled: Bool) {
        let animation: (() -> Void) = { [weak self] in
            let image = enabled ? KanvasImages.trimOn : KanvasImages.trimOff
            self?.trimButton.setBackgroundImage(image, for: .normal)
        }
        
        UIView.transition(with: trimButton,
                          duration: Constants.animationDuration,
                          options: .transitionCrossDissolve,
                          animations: animation,
                          completion: nil)
    }
    
    /// Changes the speed button image with an animation
    ///
    /// - Parameter image: the new image for the button
    func changeSpeedButton(_ enabled: Bool) {
        let animation: (() -> Void) = { [weak self] in
            let image = enabled ? KanvasImages.speedOn : KanvasImages.speedOff
            self?.speedButton.setBackgroundImage(image, for: .normal)
        }
        
        UIView.transition(with: speedButton,
                          duration: Constants.animationDuration,
                          options: .transitionCrossDissolve,
                          animations: animation,
                          completion: nil)
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        confirmButton.alpha = show ? 1 : 0
    }

    func toggleRevertButton(_ show: Bool) {
        revertButton.alpha = show ? 1 : 0
    }
}
