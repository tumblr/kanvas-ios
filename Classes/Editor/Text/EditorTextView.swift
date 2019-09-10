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
    /// Called when the font selector is tapped
    func didTapFontSelector()
    /// Called when the alignment selector is tapped
    func didTapAlignmentSelector()
}

/// Constants for EditorTextView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    
    // Overlay
    static let overlayColor = UIColor.black.withAlphaComponent(0.7)
    
    // Color collection width
    static let colorCollectionWidth: CGFloat = CircularImageView.size * 3 + CircularImageView.padding * 6
    
    // Confirm button
    static let confirmButtonSize: CGFloat = 36
    static let confirmButtonInset: CGFloat = -10
    
    // General margins
    static let topMargin: CGFloat = 19.5
    static let bottomMargin: CGFloat = 16
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
    
    // General
    static let menuIconSize: CGFloat = 36
    static let menuIconMargin: CGFloat = 36
}

/// A UIView for the text tools view
final class EditorTextView: UIView {
    
    weak var delegate: EditorTextViewDelegate?
    
    private let overlay: UIView
    private let confirmButton: UIButton
    private let textView: UITextView
    
    // Containers
    private let toolsContainer: UIView
    private let mainMenuContainer: UIView
    private let colorPickerContainer: UIView
    
    // Main menu
    private let fontSelector: UIButton
    private let alignmentSelector: UIButton
    
    // Internal properties
    let colorCollection: UIView
    
    var options: TextOptions {
        get { return textView.options }
        set {
            text = newValue.text
            textColor = newValue.color
            font = newValue.font
            alignment = newValue.alignment
        }
    }
    
    var text: String {
        get { return textView.text }
        set { textView.text = newValue }
    }
    
    var font: UIFont? {
        get { return textView.font }
        set { textView.font = newValue }
    }
    
    var textColor: UIColor? {
        get { return textView.textColor }
        set { textView.textColor = newValue }
    }
    
    var alignment: NSTextAlignment {
        get { return textView.textAlignment }
        set {
            guard let image = KanvasCameraImages.aligmentImages[newValue] else { return }
            alignmentSelector.setImage(image, for: .normal)
            textView.textAlignment = newValue
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
        overlay = UIView()
        confirmButton = ExtendedButton(inset: Constants.confirmButtonInset)
        textView = StylableTextView()
        toolsContainer = UIView()
        mainMenuContainer = UIView()
        colorPickerContainer = UIView()
        fontSelector = UIButton()
        alignmentSelector = UIButton()
        colorCollection = UIView()
        super.init(frame: .zero)
        setupViews()
    }
    
    private func setupViews() {
        setUpOverlay()
        setUpTextView()
        setUpConfirmButton()
        setUpToolsContainer()
        setUpMainMenuContainer()
        setUpColorPickerContainer()
        setUpAlignmentSelector()
        setUpFontSelector()
        setUpColorCollection()
    }
    
    
    // MARK: - Views
    
    /// Sets up the translucent black view used during text edition
    private func setUpOverlay() {
        overlay.accessibilityIdentifier = "Editor Text Overlay"
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = Constants.overlayColor
        addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    /// Sets up the main text view
    private func setUpTextView() {
        textView.accessibilityIdentifier = "Editor Text View"
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leftMargin),
            textView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.rightMargin),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        textView.alpha = 0
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(confirmButtonTapped(recognizer:)))
        confirmButton.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the container that holds the main menu and the color picker menu
    private func setUpToolsContainer() {
        toolsContainer.accessibilityIdentifier = "Editor Text Tools Container"
        toolsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toolsContainer)
        
        NSLayoutConstraint.activate([
            toolsContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.bottomMargin),
            toolsContainer.heightAnchor.constraint(equalToConstant: Constants.menuIconSize),
            toolsContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            toolsContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
        
        toolsContainer.alpha = 0
    }
    
    /// Sets up the menu that contains font selector, text alignment, colors, etc.
    private func setUpMainMenuContainer() {
        mainMenuContainer.accessibilityIdentifier = "Editor Text Main Menu Container"
        mainMenuContainer.add(into: toolsContainer)
    }
    
    /// Sets up the menu that contains eye dropper, color gradient, etc.
    private func setUpColorPickerContainer() {
        colorPickerContainer.accessibilityIdentifier = "Editor Text Color Picker Container"
        colorPickerContainer.add(into: toolsContainer)
        colorPickerContainer.alpha = 0
    }
    
    /// Sets up the alignment selector button
    private func setUpAlignmentSelector() {
        alignmentSelector.accessibilityIdentifier = "Editor Text Alignment Selector"
        alignmentSelector.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(alignmentSelector)
        
        NSLayoutConstraint.activate([
            alignmentSelector.topAnchor.constraint(equalTo: mainMenuContainer.topAnchor),
            alignmentSelector.leadingAnchor.constraint(equalTo: mainMenuContainer.leadingAnchor, constant: Constants.leftMargin),
            alignmentSelector.heightAnchor.constraint(equalToConstant: Constants.menuIconSize),
            alignmentSelector.widthAnchor.constraint(equalToConstant: Constants.menuIconSize)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(alignmentSelectorTapped(recognizer:)))
        alignmentSelector.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the font selector button
    private func setUpFontSelector() {
        fontSelector.accessibilityIdentifier = "Editor Text Font Selector"
        fontSelector.setImage(KanvasCameraImages.fontImage, for: .normal)
        fontSelector.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(fontSelector)
        
        NSLayoutConstraint.activate([
            fontSelector.topAnchor.constraint(equalTo: mainMenuContainer.topAnchor),
            fontSelector.leadingAnchor.constraint(equalTo: alignmentSelector.trailingAnchor, constant: Constants.menuIconMargin),
            fontSelector.heightAnchor.constraint(equalToConstant: Constants.menuIconSize),
            fontSelector.widthAnchor.constraint(equalToConstant: Constants.menuIconSize)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(fontSelectorTapped(recognizer:)))
        fontSelector.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the color carousel shown at the right of the main menu
    private func setUpColorCollection() {
        colorCollection.backgroundColor = .clear
        colorCollection.accessibilityIdentifier = "Editor Text Color Collection Container"
        colorCollection.clipsToBounds = false
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(colorCollection)
        
        NSLayoutConstraint.activate([
            colorCollection.widthAnchor.constraint(equalToConstant: Constants.colorCollectionWidth),
            colorCollection.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            colorCollection.centerYAnchor.constraint(equalTo: mainMenuContainer.centerYAnchor),
            colorCollection.heightAnchor.constraint(equalToConstant: CircularImageView.size)
        ])
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func confirmButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapConfirmButton()
    }
    
    @objc private func fontSelectorTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapFontSelector()
    }
    
    @objc private func alignmentSelectorTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapAlignmentSelector()
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
    
    /// Moves up the text view and the tools menu
    ///
    /// - Parameter distance: space from original position
    func moveToolsUp(distance: CGFloat) {
        UIView.animate(withDuration: 0.0, animations: {
            self.textView.frame = CGRect(x: self.textView.frame.origin.x,
                                         y: self.textView.frame.origin.y,
                                         width: self.textView.frame.width,
                                         height: self.frame.height - self.toolsContainer.frame.height - Constants.bottomMargin - distance)
            self.toolsContainer.transform = CGAffineTransform(translationX: 0, y: -distance)
        }, completion: { _ in
            self.showTools(true)
            self.showTextView(true)
        })
    }
    
    /// Moves the text view and the tools menu to their original position
    func moveToolsDown() {
        showTextView(false)
        showTools(false)

        textView.frame = CGRect(x: textView.frame.origin.x,
                                y: textView.frame.origin.y,
                                width: textView.frame.width,
                                height: frame.height - self.toolsContainer.frame.height - Constants.bottomMargin)
        toolsContainer.transform = .identity
    }
    
    // MARK: - Private utilitites
    
    /// shows or hides the main text view
    ///
    /// - Parameter show: true to show, false to hide
    private func showTextView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.textView.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the tools container
    ///
    /// - Parameter show: true to show, false to hide
    private func showTools(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.toolsContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the color picker menu
    ///
    /// - Parameter show: true to show, false to hide
    private func showColorPickerMenu(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.colorPickerContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the main menu
    ///
    /// - Parameter show: true to show, false to hide
    private func showMainMenu(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.mainMenuContainer.alpha = show ? 1 : 0
        }
    }
}
