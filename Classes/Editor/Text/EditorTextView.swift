//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for the text tools editor
protocol EditorTextViewDelegate: class {
    
    /// Called when the confirm button is selected
    func didTapConfirmButton()
    /// Called when the text view background is tapped
    func didTapTextViewBackground()
    /// Called when the font selector is tapped
    func didTapFontSelector()
    /// Called when the alignment selector is tapped
    func didTapAlignmentSelector()
    /// Called when the eye dropper is tapped
    func didTapEyeDropper()
}

/// Constants for EditorTextView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let noDuration: TimeInterval = 0.0
    static let brightnessThreshold: Double = 0.8
    
    // General margins
    static let topMargin: CGFloat = 19.5
    static let bottomMargin: CGFloat = 16
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
    
    // Text view
    static let textViewLeftMargin: CGFloat = 14
    static let textViewRightMargin: CGFloat = 14
    
    // Menu buttons
    static let customIconSize: CGFloat = 36
    static let customIconMargin: CGFloat = 36
    static let circularIconSize: CGFloat = CircularImageView.size
    static let circularIconPadding: CGFloat = CircularImageView.padding
    static let circularIconBorderWidth: CGFloat = 2
    static let circularIconBorderColor: UIColor = .white
    static let circularIconCornerRadius: CGFloat = circularIconSize / 2

    // Color collection width
    static let colorCollectionWidth: CGFloat = circularIconSize * 3 + circularIconPadding * 6
    
    // Confirm button
    static let confirmButtonSize: CGFloat = 36
    static let confirmButtonInset: CGFloat = -10
}

/// A UIView for the text tools view
final class EditorTextView: UIView, StylableTextViewDelegate {
    
    weak var delegate: EditorTextViewDelegate?
    
    private let confirmButton: UIButton
    private let textView: StylableTextView
    private var textViewHeight: NSLayoutConstraint?
    
    // Containers
    private let toolsContainer: UIView
    private let mainMenuContainer: UIView
    private let colorPickerContainer: UIView
    
    // Main menu
    private let fontSelector: UIButton
    private let alignmentSelector: UIButton
    private let openColorPicker: UIButton
    
    // Color picker menu
    private let closeColorPicker: UIButton
    private let eyeDropper: UIButton
    
    // Color selector
    var colorSelectorOrigin: CGPoint {
        return colorPickerContainer.convert(eyeDropper.center, to: self)
    }
    
    // Internal properties
    let colorCollection: UIView
    let colorGradient: UIView
    let colorSelector: UIView
    
    var options: TextOptions {
        get { return textView.options }
        set {
            text = newValue.text
            textColor = newValue.color
            font = newValue.font
            alignment = newValue.alignment
            textContainerInset = newValue.textContainerInset
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
        set {
            guard let color = newValue else { return }
            eyeDropper.backgroundColor = color
            eyeDropper.tintColor = color.isAlmostWhite() ? .black : .white
            textView.textColor = color
        }
    }
    
    var alignment: NSTextAlignment {
        get { return textView.textAlignment }
        set {
            guard let image = KanvasCameraImages.aligmentImages[newValue] else { return }
            alignmentSelector.setImage(image, for: .normal)
            textView.textAlignment = newValue
        }
    }
    
    var textContainerInset: UIEdgeInsets {
        get { return textView.textContainerInset }
        set { textView.textContainerInset = newValue }
    }
    
    private var croppedView: UITextView {
        let view = UITextView(frame: textView.frame)
        view.options = textView.options
        view.sizeToFit()
        return view
    }
    
    /// Center of the text view in screen coordinates
    var location: CGPoint {
        let point = textView.center
        let margin = (textView.bounds.width - croppedView.bounds.width) / 2
        
        let difference: CGFloat
        switch textView.textAlignment {
        case .left:
            difference = -margin
        case .right:
            difference = margin
        default:
            difference = 0
        }
        
        return CGPoint(x: point.x + difference, y: point.y)
    }
    
    /// Size of the text view
    var textSize: CGSize {
        return croppedView.contentSize
    }
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        confirmButton = ExtendedButton(inset: Constants.confirmButtonInset)
        textView = StylableTextView()
        toolsContainer = UIView()
        mainMenuContainer = UIView()
        colorPickerContainer = UIView()
        alignmentSelector = UIButton()
        fontSelector = UIButton()
        colorCollection = UIView()
        openColorPicker = UIButton()
        closeColorPicker = UIButton()
        eyeDropper = UIButton()
        colorGradient = UIView()
        colorSelector = IgnoreTouchesView()
        super.init(frame: .zero)
        textView.textViewDelegate = self
        setupViews()
    }
    
    private func setupViews() {
        setUpTextView()
        setUpConfirmButton()
        setUpToolsContainer()
        setUpMainMenuContainer()
        setUpColorPickerContainer()
        setUpAlignmentSelector()
        setUpFontSelector()
        setUpColorCollection()
        setUpOpenColorPicker()
        setUpCloseColorPicker()
        setUpEyeDropper()
        setUpColorGradient()
        setUpColorSelector()
    }
    
    
    // MARK: - Views
    
    /// Sets up the main text view
    private func setUpTextView() {
        textView.accessibilityIdentifier = "Editor Text View"
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        textViewHeight = textView.heightAnchor.constraint(equalTo: heightAnchor)
        textViewHeight?.isActive = true
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.textViewLeftMargin),
            textView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.textViewRightMargin),
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
            toolsContainer.heightAnchor.constraint(equalToConstant: Constants.customIconSize),
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
            alignmentSelector.heightAnchor.constraint(equalToConstant: Constants.customIconSize),
            alignmentSelector.widthAnchor.constraint(equalToConstant: Constants.customIconSize)
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
            fontSelector.leadingAnchor.constraint(equalTo: alignmentSelector.trailingAnchor, constant: Constants.customIconMargin),
            fontSelector.heightAnchor.constraint(equalToConstant: Constants.customIconSize),
            fontSelector.widthAnchor.constraint(equalToConstant: Constants.customIconSize)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(fontSelectorTapped(recognizer:)))
        fontSelector.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the color carousel shown at the right of the main menu
    private func setUpColorCollection() {
        colorCollection.accessibilityIdentifier = "Editor Text Color Collection"
        colorCollection.clipsToBounds = false
        colorCollection.backgroundColor = .clear
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(colorCollection)
        
        NSLayoutConstraint.activate([
            colorCollection.widthAnchor.constraint(equalToConstant: Constants.colorCollectionWidth),
            colorCollection.trailingAnchor.constraint(equalTo: mainMenuContainer.trailingAnchor),
            colorCollection.centerYAnchor.constraint(equalTo: mainMenuContainer.centerYAnchor),
            colorCollection.heightAnchor.constraint(equalToConstant: Constants.circularIconSize)
        ])
    }
    
    /// Sets up the gradient button that opens the color picker menu
    private func setUpOpenColorPicker() {
        openColorPicker.accessibilityIdentifier = "Editor Text Open Color Picker"
        openColorPicker.setImage(KanvasCameraImages.gradientImage, for: .normal)
        openColorPicker.layer.borderColor = Constants.circularIconBorderColor.cgColor
        openColorPicker.layer.borderWidth = Constants.circularIconBorderWidth
        openColorPicker.layer.cornerRadius = Constants.circularIconCornerRadius
        openColorPicker.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(openColorPicker)
        
        NSLayoutConstraint.activate([
            openColorPicker.trailingAnchor.constraint(equalTo: colorCollection.leadingAnchor, constant: -Constants.circularIconPadding),
            openColorPicker.centerYAnchor.constraint(equalTo: mainMenuContainer.centerYAnchor),
            openColorPicker.heightAnchor.constraint(equalToConstant: Constants.circularIconSize),
            openColorPicker.widthAnchor.constraint(equalToConstant: Constants.circularIconSize),
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openColorPickerTapped(recognizer:)))
        openColorPicker.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the cross button to close the color picker menu
    private func setUpCloseColorPicker() {
        closeColorPicker.accessibilityIdentifier = "Editor Text Close Color Picker"
        closeColorPicker.setImage(KanvasCameraImages.closeGradientImage, for: .normal)
        closeColorPicker.translatesAutoresizingMaskIntoConstraints = false
        colorPickerContainer.addSubview(closeColorPicker)
        
        NSLayoutConstraint.activate([
            closeColorPicker.leadingAnchor.constraint(equalTo: colorPickerContainer.leadingAnchor, constant: Constants.leftMargin),
            closeColorPicker.centerYAnchor.constraint(equalTo: colorPickerContainer.centerYAnchor),
            closeColorPicker.heightAnchor.constraint(equalToConstant: Constants.circularIconSize),
            closeColorPicker.widthAnchor.constraint(equalToConstant: Constants.circularIconSize),
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeColorPickerTapped(recognizer:)))
        closeColorPicker.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the eye dropper button in the color picker menu
    private func setUpEyeDropper() {
        eyeDropper.accessibilityIdentifier = "Editor Text Eye Dropper"
        let image = KanvasCameraImages.eyeDropperImage?.withRenderingMode(.alwaysTemplate)
        eyeDropper.setImage(image, for: .normal)
        eyeDropper.layer.borderColor = Constants.circularIconBorderColor.cgColor
        eyeDropper.layer.borderWidth = Constants.circularIconBorderWidth
        eyeDropper.layer.cornerRadius = Constants.circularIconCornerRadius
        eyeDropper.translatesAutoresizingMaskIntoConstraints = false
        colorPickerContainer.addSubview(eyeDropper)
        
        NSLayoutConstraint.activate([
            eyeDropper.leadingAnchor.constraint(equalTo: closeColorPicker.trailingAnchor, constant: Constants.circularIconPadding * 2),
            eyeDropper.centerYAnchor.constraint(equalTo: colorPickerContainer.centerYAnchor),
            eyeDropper.heightAnchor.constraint(equalToConstant: Constants.circularIconSize),
            eyeDropper.widthAnchor.constraint(equalToConstant: Constants.circularIconSize),
        ])
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(eyeDropperTapped(recognizer:)))
        eyeDropper.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the horizontal gradient in the color picker menu
    private func setUpColorGradient() {
        colorGradient.accessibilityIdentifier = "Editor Text Color Gradient"
        colorGradient.backgroundColor = .clear
        colorGradient.clipsToBounds = false
        colorGradient.translatesAutoresizingMaskIntoConstraints = false
        colorPickerContainer.addSubview(colorGradient)
        
        NSLayoutConstraint.activate([
            colorGradient.leadingAnchor.constraint(equalTo: eyeDropper.trailingAnchor, constant: Constants.circularIconPadding * 2),
            colorGradient.trailingAnchor.constraint(equalTo: colorPickerContainer.trailingAnchor, constant: -Constants.rightMargin),
            colorGradient.centerYAnchor.constraint(equalTo: colorPickerContainer.centerYAnchor),
            colorGradient.heightAnchor.constraint(equalToConstant: Constants.circularIconSize),
        ])
    }
    
    /// Sets up the color circle that is shown when tapping the eye dropper
    private func setUpColorSelector() {
        colorSelector.accessibilityIdentifier = "Editor Text Color Selector"
        colorSelector.backgroundColor = .clear
        colorSelector.clipsToBounds = false
        colorSelector.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorSelector)
        
        NSLayoutConstraint.activate([
            colorSelector.topAnchor.constraint(equalTo: topAnchor),
            colorSelector.bottomAnchor.constraint(equalTo: bottomAnchor),
            colorSelector.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorSelector.trailingAnchor.constraint(equalTo: trailingAnchor),
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
    
    @objc private func openColorPickerTapped(recognizer: UITapGestureRecognizer) {
        showMainMenu(false)
        showColorPickerMenu(true)
    }
    
    @objc private func closeColorPickerTapped(recognizer: UITapGestureRecognizer) {
        showColorPickerMenu(false)
        showMainMenu(true)
    }
    
    @objc private func eyeDropperTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapEyeDropper()
    }
    
    // MARK: - StylableViewDelegate
    
    func didTapBackground() {
        delegate?.didTapTextViewBackground()
    }
    
    // MARK: - Public interface
    
    /// Focuses the main text view to show the keyboard
    func startWriting() {
        colorPickerContainer.alpha = 0
        mainMenuContainer.alpha = 1
        openKeyboard()
    }
    
    /// Closes the keyboard and clears the main text view
    func endWriting() {
        closeKeyboard()
        textView.text = nil
    }
    
    /// Opens the keyboard
    func openKeyboard() {
        textView.becomeFirstResponder()
    }
    
    /// Closes the keyboard
    func closeKeyboard() {
        textView.endEditing(true)
    }
    
    /// Moves up the text view and the tools menu
    ///
    /// - Parameter distance: space from original position
    func moveToolsUp(distance: CGFloat) {
        UIView.performWithoutAnimation {
            textViewHeight?.constant = -(toolsContainer.frame.height + Constants.bottomMargin + distance)
            textView.setNeedsLayout()
            textView.layoutIfNeeded()
        }
        
        toolsContainer.transform = CGAffineTransform(translationX: 0, y: -distance)
        toolsContainer.alpha = 1
        textView.alpha = 1
        confirmButton.alpha = 1
    }
    
    /// Moves the text view and the tools menu to their original position
    func moveToolsDown() {
        confirmButton.alpha = 0
        toolsContainer.alpha = 0
        toolsContainer.transform = .identity
        
        UIView.performWithoutAnimation {
            textView.alpha = 0
            textViewHeight?.constant = -(toolsContainer.frame.height + Constants.bottomMargin)
            textView.setNeedsLayout()
            textView.layoutIfNeeded()
        }
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
    
    // MARK: - Private utilities
    
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

private extension UIColor {
    
    func isAlmostWhite() -> Bool {
        return brightness > Constants.brightnessThreshold
    }
}
