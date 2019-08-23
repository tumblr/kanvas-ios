//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for closing the text tools
protocol TextViewDelegate: class {
    
    /// Called when the confirm button is selected
    func didTapConfirmButton()
}

/// Constants for TextView
private struct Constants {
    
    // Confirm button
    static let confirmButtonSize: CGFloat = 36
    static let confirmButtonInset: CGFloat = -10
    
    // Icon margins
    static let topMargin: CGFloat = 19.5
    static let bottomMargin: CGFloat = 25
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
}

/// A UIView for the text tools view
final class TextView: UIView {
    
    weak var delegate: TextViewDelegate?
    
    private let confirmButton: UIButton
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        confirmButton = ExtendedButton(inset: Constants.confirmButtonInset)
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        setUpConfirmButton()
    }
    
    
    // MARK: - Views
    
    private func setUpConfirmButton() {
        confirmButton.accessibilityIdentifier = "Editor Text Confirm Button"
        confirmButton.setBackgroundImage(KanvasCameraImages.editorConfirmImage, for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.topMargin),
            confirmButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.rightMargin),
            confirmButton.heightAnchor.constraint(equalToConstant: Constants.confirmButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: Constants.confirmButtonSize)
        ])
        
        let confirmButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(confirmButtonTapped(recognizer:)))
        confirmButton.addGestureRecognizer(confirmButtonRecognizer)
    }
    
    
    // MARK: - Gesture recognizers
    
    @objc private func confirmButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapConfirmButton()
    }
}

