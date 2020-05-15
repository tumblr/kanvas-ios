//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for closing the GIF maker
protocol GifMakerViewDelegate: class {
    
    /// Called when the confirm button is selected
    func didTapConfirmButton()
    
    /// Called when the trim button is selected
    func didTapTrimButton()
}

/// Constants for GifMakerView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    
    // General margins
    static let topMargin: CGFloat = 19.5
    static let bottomMargin: CGFloat = 16
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
    
    // Top options
    static let topButtonSize: CGFloat = 36
    static let confirmButtonInset: CGFloat = -10
    static let topButtonsInterspace: CGFloat = 30
}

/// A UIView for the GIF maker view
final class GifMakerView: UIView {
    
    weak var delegate: GifMakerViewDelegate?
    
    private let confirmButton: UIButton
    private let trimButton: UIButton
    private let topButtonsContainer: UIView
    let trimMenuContainer: IgnoreTouchesView
    
    /// Confirm button location expressed in screen coordinates
    var confirmButtonLocation: CGPoint {
        return topButtonsContainer.convert(confirmButton.center, to: nil)
    }
    
    // MARK: - Initializers
    
    init() {
        confirmButton = ExtendedButton(inset: Constants.confirmButtonInset)
        trimButton = ExtendedButton(inset: Constants.confirmButtonInset)
        topButtonsContainer = IgnoreTouchesView()
        trimMenuContainer = IgnoreTouchesView()
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
        setupTrimMenuContainer()
    }
    
    /// Sets up the container for the top buttons
    private func setUpTopButtonsContainer() {
        topButtonsContainer.accessibilityIdentifier = "GIF Maker Top Buttons Container"
        topButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topButtonsContainer)
        
        let height = Constants.topButtonSize * 2 + Constants.topButtonsInterspace
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
        confirmButton.setBackgroundImage(KanvasCameraImages.editorConfirmImage, for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        topButtonsContainer.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.centerXAnchor.constraint(equalTo: topButtonsContainer.centerXAnchor),
            confirmButton.topAnchor.constraint(equalTo: topButtonsContainer.topAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: Constants.topButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: Constants.topButtonSize)
        ])
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        confirmButton.alpha = 0
    }
    
    /// Sets up the trim button in the top options
    private func setUpTrimButton() {
        trimButton.accessibilityIdentifier = "GIF Maker Trim Button"
        trimButton.setBackgroundImage(KanvasCameraImages.trimOff, for: .normal)
        trimButton.translatesAutoresizingMaskIntoConstraints = false
        topButtonsContainer.addSubview(trimButton)
        
        let topOffset = Constants.topButtonSize + Constants.topButtonsInterspace
        NSLayoutConstraint.activate([
            trimButton.centerXAnchor.constraint(equalTo: topButtonsContainer.centerXAnchor ),
            trimButton.topAnchor.constraint(equalTo: topButtonsContainer.topAnchor, constant: topOffset),
            trimButton.heightAnchor.constraint(equalToConstant: Constants.topButtonSize),
            trimButton.widthAnchor.constraint(equalToConstant: Constants.topButtonSize)
        ])
        
        trimButton.addTarget(self, action: #selector(trimButtonTapped), for: .touchUpInside)
    }
    
    private func setupTrimMenuContainer() {
        trimMenuContainer.backgroundColor = .clear
        trimMenuContainer.accessibilityIdentifier = "GIF Maker Trim Menu Container"
        trimMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        trimMenuContainer.clipsToBounds = false
        
        addSubview(trimMenuContainer)
        NSLayoutConstraint.activate([
            trimMenuContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leftMargin),
            trimMenuContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.rightMargin),
            trimMenuContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomMargin),
            trimMenuContainer.heightAnchor.constraint(equalToConstant: TrimView.height),
        ])
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func confirmButtonTapped() {
        delegate?.didTapConfirmButton()
    }
    
    @objc private func trimButtonTapped() {
        delegate?.didTapTrimButton()
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
    
    
    /// Changes the image with an animation
    ///
    /// - Parameter image: the new image for the button
    func changeTrimButton(_ enabled: Bool) {
        let animation: (() -> Void) = { [weak self] in
            let image = enabled ? KanvasCameraImages.trimOn : KanvasCameraImages.trimOff
            self?.trimButton.setBackgroundImage(image, for: .normal)
        }
        
        UIView.transition(with: trimButton,
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
}
