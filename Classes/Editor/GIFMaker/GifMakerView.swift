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
}

/// Constants for GifMakerView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    
    // General margins
    static let topMargin: CGFloat = 19.5
    static let bottomMargin: CGFloat = 16
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
    
    // Confirm button
    static let confirmButtonSize: CGFloat = 36
    static let confirmButtonInset: CGFloat = -10
}

/// A UIView for the GIF maker view
final class GifMakerView: UIView {
    
    weak var delegate: GifMakerViewDelegate?
    
    private let confirmButton: UIButton
    private let topButtonsContainer: UIView
    
    /// Confirm button location expressed in screen coordinates
    var confirmButtonLocation: CGPoint {
        return topButtonsContainer.convert(confirmButton.center, to: nil)
    }
    
    // MARK: - Initializers
    
    init() {
        confirmButton = ExtendedButton(inset: Constants.confirmButtonInset)
        topButtonsContainer = IgnoreTouchesView()
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
    }
    
    /// Sets up the container for the top buttons
    private func setUpTopButtonsContainer() {
        topButtonsContainer.accessibilityIdentifier = "GIF Maker Top Buttons Container"
        topButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topButtonsContainer)
        
        NSLayoutConstraint.activate([
            topButtonsContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topMargin),
            topButtonsContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.rightMargin),
            topButtonsContainer.heightAnchor.constraint(equalToConstant: Constants.confirmButtonSize),
            topButtonsContainer.widthAnchor.constraint(equalToConstant: Constants.confirmButtonSize)
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
            confirmButton.centerYAnchor.constraint(equalTo: topButtonsContainer.centerYAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: Constants.confirmButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: Constants.confirmButtonSize)
        ])
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        confirmButton.alpha = 0
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func confirmButtonTapped() {
        delegate?.didTapConfirmButton()
    }
    
    // MARK: - Public interface
    
    /// shows or hides the view
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            self?.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        confirmButton.alpha = show ? 1 : 0
    }
}
