//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for closing the text tools
protocol EditorTextViewDelegate: class {
    
    /// Called when the confirm button is selected
    func didTapConfirmButton()
}

/// Constants for EditorTextView
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
final class EditorTextView: UIView {
    
    weak var delegate: EditorTextViewDelegate?
    
    private let confirmButton: UIButton
    private let textView: UITextView
    
    var textOptions: TextOptions {
        get {
            return textView.options
        }
        set {
            textView.options = newValue
        }
    }
    
    /// Size of the text view
    var textSize: CGSize {
        let croppedView = UITextView(frame: textView.frame)
        croppedView.options = textView.options
        croppedView.sizeToFit()
        return croppedView.contentSize
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        confirmButton = ExtendedButton(inset: Constants.confirmButtonInset)
        textView = VerticallyCenteredTextView()
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        setUpTextView()
        setUpConfirmButton()
    }
    
    
    // MARK: - Views
    
    /// Sets up the main text view
    private func setUpTextView() {
        textView.accessibilityIdentifier = "Editor Text View"
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    /// Sets up the confirmation button with a check mark
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
    
    // MARK: - Public interface
    
    /// Focuses the main text view to show the keyboard
    func startWriting() {
        textView.becomeFirstResponder()
    }
    
    /// Closes the keyboard and clears the main text view
    func endWriting() {
        textView.endEditing(true)
        textView.text = nil
    }
    
    /// Moves the main text view up
    ///
    /// - Parameter distance: space from original position
    func moveToolsUp(distance: CGFloat) {
        textView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - distance)
    }
    
    /// Moves the main text view to its original position
    func moveToolsDown() {
        textView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
}

/// Text view that vertically aligns the text on its center
private class VerticallyCenteredTextView: UITextView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}
