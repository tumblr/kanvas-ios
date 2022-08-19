//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for the text tools editor
protocol EditorTextViewDelegate: AnyObject {
    
    /// Called when the confirm button is selected
    func didTapConfirmButton()
    /// Called when the text view background is tapped
    func didTapTextViewBackground()
    /// Called when the alignment selector is tapped
    func didTapAlignmentSelector()
    /// Called when the font selector is tapped
    func didTapFontSelector()
    /// Called when the highlight selector is tapped
    func didTapHighlightSelector()
    /// Called when the eye dropper is tapped
    func didTapEyeDropper()
}

/// Constants for EditorTextView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let noDuration: TimeInterval = 0.0
    
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
    static let customIconMargin: CGFloat = 18
    static let circularIconSize: CGFloat = CircularImageView.size
    static let circularIconPadding: CGFloat = CircularImageView.padding
    static let circularIconBorderWidth: CGFloat = 2
    static let circularIconBorderColor: UIColor = .white
    static let circularIconCornerRadius: CGFloat = circularIconSize / 2

    // Confirm button
    static let confirmButtonSize: CGFloat = KanvasEditorDesign.shared.topButtonSize
    static let confirmButtonInset: CGFloat = -10
}

/// A UIView for the text tools view
final class EditorTextView: UIView, MainTextViewDelegate {
    
    weak var delegate: EditorTextViewDelegate?
    
    private let confirmButton: UIButton
    private let mainTextView: MainTextView
    private var mainTextViewHeight: NSLayoutConstraint?
    
    // Containers
    private let toolsContainer: UIView
    private let mainMenuContainer: UIView
    private let colorPickerContainer: UIView
    private let topButtonsContainer: UIView
    
    // Main menu
    private let fontSelector: UIButton
    private let alignmentSelector: UIButton
    private let highlightSelector: UIButton
    private let openColorPicker: UIButton
    
    // Color picker menu
    private let closeColorPicker: UIButton
    private let eyeDropper: UIButton
    
    // Color selector
    var colorSelectorOrigin: CGPoint {
        return colorPickerContainer.convert(eyeDropper.center, to: self)
    }
    
    /// Confirm button location expressed in screen coordinates
    var confirmButtonLocation: CGPoint {
        return topButtonsContainer.convert(confirmButton.center, to: nil)
    }
    
    // Internal properties
    let colorCollection: UIView
    let colorGradient: UIView
    let colorSelector: UIView
    
    var options: TextOptions {
        get { return mainTextView.options }
        set {
            text = newValue.text
            textColor = newValue.color
            highlightColor = newValue.highlightColor
            font = newValue.font
            alignment = newValue.alignment
            textContainerInset = newValue.textContainerInset
        }
    }
    
    var text: String {
        get { return mainTextView.text }
        set { mainTextView.text = newValue }
    }
    
    var font: UIFont? {
        get { return mainTextView.font }
        set {
            mainTextView.font = newValue
            mainTextView.resizeFont()

            if settings.fontSelectorUsesFont {
                refreshFontSelector()
            }
        }
    }
    
    var textColor: UIColor? {
        get { return mainTextView.textColor }
        set { mainTextView.textColor = newValue }
    }
    
    var highlightColor: UIColor? {
        get { return mainTextView.highlightColor }
        set {
            guard let newColor = newValue, let image = KanvasEditorDesign.shared.editorTextViewHighlightImage(newColor.isVisible()) else { return }
            highlightSelector.setImage(image, for: .normal)
            mainTextView.highlightColor = newColor
        }
    }
    
    var eyeDropperColor: UIColor? {
        get { return eyeDropper.backgroundColor }
        set {
            guard let newColor = newValue else { return }
            eyeDropper.backgroundColor = newColor
            eyeDropper.tintColor = newColor.matchingColor()
        }
    }
    
    var alignment: NSTextAlignment {
        get { return mainTextView.textAlignment }
        set {
            guard let image = KanvasEditorDesign.shared.editorTextViewAlignmentImage[newValue] else { return }
            alignmentSelector.setImage(image, for: .normal)
            mainTextView.textAlignment = newValue
        }
    }
    
    var textContainerInset: UIEdgeInsets {
        get { return mainTextView.textContainerInset }
        set { mainTextView.textContainerInset = newValue }
    }
    
    private var croppedView: UITextView {
        let view = StylableTextView(frame: mainTextView.frame)
        view.options = mainTextView.options
        view.sizeToFit()
        return view
    }
    
    /// Center of the text view in screen coordinates
    var location: CGPoint {
        let point = mainTextView.center
        let margin = (mainTextView.bounds.width - croppedView.bounds.width) / 2
        
        let difference: CGFloat
        switch mainTextView.textAlignment {
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
        let croppedView = StylableTextView(frame: mainTextView.frame)
        croppedView.options = mainTextView.options
        croppedView.sizeToFit()
        return croppedView.contentSize
    }

    struct Settings {
        /// The Font Selector button uses the current selected font (`font`) for its label
        let fontSelectorUsesFont: Bool
        /// Enables/disables progressive font resizing
        let resizesFonts: Bool
    }

    private let settings: Settings
    
    @available(*, unavailable, message: "use init() instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(settings inSettings: Settings) {
        confirmButton = ExtendedButton(inset: Constants.confirmButtonInset)
        mainTextView = MainTextView()
        toolsContainer = UIView()
        mainMenuContainer = UIView()
        colorPickerContainer = UIView()
        topButtonsContainer = IgnoreTouchesView()
        alignmentSelector = UIButton()
        fontSelector = UIButton()
        highlightSelector = UIButton()
        colorCollection = UIView()
        openColorPicker = UIButton()
        closeColorPicker = UIButton()
        eyeDropper = UIButton()
        colorGradient = UIView()
        colorSelector = IgnoreTouchesView()
        settings = inSettings
        super.init(frame: .zero)
        mainTextView.textViewDelegate = self
        setupViews()
    }
    
    private func setupViews() {
        setUpMainTextView()
        setUpTopButtonsContainer()
        setUpConfirmButton()
        setUpToolsContainer()
        setUpMainMenuContainer()
        setUpColorPickerContainer()
        setUpFontSelector()
        setUpAlignmentSelector()
        setUpHighlightSelector()
        setUpOpenColorPicker()
        setUpColorCollection()
        setUpCloseColorPicker()
        setUpEyeDropper()
        setUpColorGradient()
        setUpColorSelector()
    }
    
    // MARK: - Views
    
    /// Sets up the main text view
    private func setUpMainTextView() {
        mainTextView.accessibilityIdentifier = "Editor Text Main View"
        mainTextView.translatesAutoresizingMaskIntoConstraints = false
        mainTextView.resizesFont = settings.resizesFonts
        addSubview(mainTextView)
        
        let topMargin = Constants.topMargin + Constants.confirmButtonSize
        mainTextViewHeight = mainTextView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, constant: -topMargin)
        mainTextViewHeight?.isActive = true
        NSLayoutConstraint.activate([
            mainTextView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: topMargin),
            mainTextView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.textViewLeftMargin),
            mainTextView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.textViewRightMargin),
        ])
        
        mainTextView.alpha = 0
    }
    
    /// Sets up the confirmation button with a check mark
    private func setUpTopButtonsContainer() {
        topButtonsContainer.accessibilityIdentifier = "Editor Text Top Buttons Container"
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
        confirmButton.accessibilityIdentifier = "Editor Text Confirm Button"
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        topButtonsContainer.addSubview(confirmButton)
        
        let checkmark = KanvasEditorDesign.shared.checkmarkImage
        if KanvasEditorDesign.shared.isVerticalMenu {
            let backgroundImage = UIImage.circle(diameter: Constants.confirmButtonSize, color: KanvasColors.shared.primaryButtonBackgroundColor)
            confirmButton.setBackgroundImage(backgroundImage, for: .normal)
            confirmButton.setImage(checkmark, for: .normal)
        }
        else {
            confirmButton.setBackgroundImage(checkmark, for: .normal)
        }
        
        NSLayoutConstraint.activate([
            confirmButton.centerXAnchor.constraint(equalTo: topButtonsContainer.centerXAnchor),
            confirmButton.centerYAnchor.constraint(equalTo: topButtonsContainer.centerYAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: Constants.confirmButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: Constants.confirmButtonSize)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(confirmButtonTapped(recognizer:)))
        confirmButton.addGestureRecognizer(tapRecognizer)
        
        confirmButton.alpha = 0
    }

    private func refreshFontSelector() {
        if let attributedFont = font?.withSize(20) {
            fontSelector.setAttributedTitle(NSAttributedString(string: "Aa", attributes: [.font: attributedFont, .foregroundColor: UIColor.white]), for: .normal)
        }
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
    
    /// Sets up the font selector button
    private func setUpFontSelector() {
        fontSelector.accessibilityIdentifier = "Editor Text Font Selector"
        if settings.fontSelectorUsesFont {
            refreshFontSelector()
        } else {
            fontSelector.setImage(KanvasImages.fontImage, for: .normal)
        }
        fontSelector.layer.cornerRadius = Constants.customIconSize / 2
        fontSelector.backgroundColor = KanvasEditorDesign.shared.buttonBackgroundColor
        fontSelector.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(fontSelector)
        
        NSLayoutConstraint.activate([
            fontSelector.topAnchor.constraint(equalTo: mainMenuContainer.topAnchor),
            fontSelector.leadingAnchor.constraint(equalTo: mainMenuContainer.leadingAnchor, constant: Constants.leftMargin),
            fontSelector.heightAnchor.constraint(equalToConstant: Constants.customIconSize),
            fontSelector.widthAnchor.constraint(equalToConstant: Constants.customIconSize)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(fontSelectorTapped(recognizer:)))
        fontSelector.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the alignment selector button
    private func setUpAlignmentSelector() {
        alignmentSelector.accessibilityIdentifier = "Editor Text Alignment Selector"
        alignmentSelector.layer.cornerRadius = Constants.customIconSize / 2
        alignmentSelector.backgroundColor = KanvasEditorDesign.shared.buttonBackgroundColor
        alignmentSelector.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(alignmentSelector)
        
        NSLayoutConstraint.activate([
            alignmentSelector.topAnchor.constraint(equalTo: mainMenuContainer.topAnchor),
            alignmentSelector.leadingAnchor.constraint(equalTo: fontSelector.trailingAnchor, constant: Constants.customIconMargin),
            alignmentSelector.heightAnchor.constraint(equalToConstant: Constants.customIconSize),
            alignmentSelector.widthAnchor.constraint(equalToConstant: Constants.customIconSize)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(alignmentSelectorTapped(recognizer:)))
        alignmentSelector.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the highlight selector button
    private func setUpHighlightSelector() {
        highlightSelector.accessibilityIdentifier = "Editor Text Font Selector"
        highlightSelector.layer.cornerRadius = Constants.customIconSize / 2
        highlightSelector.backgroundColor = KanvasEditorDesign.shared.buttonBackgroundColor
        highlightSelector.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(highlightSelector)
        
        NSLayoutConstraint.activate([
            highlightSelector.topAnchor.constraint(equalTo: mainMenuContainer.topAnchor),
            highlightSelector.leadingAnchor.constraint(equalTo: alignmentSelector.trailingAnchor, constant: Constants.customIconMargin),
            highlightSelector.heightAnchor.constraint(equalToConstant: Constants.customIconSize),
            highlightSelector.widthAnchor.constraint(equalToConstant: Constants.customIconSize)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(highlightSelectorTapped(recognizer:)))
        highlightSelector.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the gradient button that opens the color picker menu
    private func setUpOpenColorPicker() {
        openColorPicker.accessibilityIdentifier = "Editor Text Open Color Picker"
        openColorPicker.setImage(KanvasImages.gradientImage, for: .normal)
        openColorPicker.layer.borderColor = Constants.circularIconBorderColor.cgColor
        openColorPicker.layer.borderWidth = Constants.circularIconBorderWidth
        openColorPicker.layer.cornerRadius = Constants.circularIconCornerRadius
        openColorPicker.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(openColorPicker)
        
        NSLayoutConstraint.activate([
            openColorPicker.centerYAnchor.constraint(equalTo: mainMenuContainer.centerYAnchor),
            openColorPicker.leadingAnchor.constraint(equalTo: highlightSelector.trailingAnchor, constant: Constants.customIconMargin),
            openColorPicker.heightAnchor.constraint(equalToConstant: Constants.circularIconSize),
            openColorPicker.widthAnchor.constraint(equalToConstant: Constants.circularIconSize)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openColorPickerTapped(recognizer:)))
        openColorPicker.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the color carousel shown at the right of the main menu
    private func setUpColorCollection() {
        colorCollection.accessibilityIdentifier = "Editor Text Color Collection"
        colorCollection.clipsToBounds = false
        colorCollection.backgroundColor = .clear
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        mainMenuContainer.addSubview(colorCollection)
        
        NSLayoutConstraint.activate([
            colorCollection.leadingAnchor.constraint(equalTo: openColorPicker.trailingAnchor, constant: Constants.circularIconPadding),
            colorCollection.trailingAnchor.constraint(equalTo: mainMenuContainer.trailingAnchor),
            colorCollection.centerYAnchor.constraint(equalTo: mainMenuContainer.centerYAnchor),
            colorCollection.heightAnchor.constraint(equalToConstant: Constants.circularIconSize)
        ])
    }
    
    /// Sets up the cross button to close the color picker menu
    private func setUpCloseColorPicker() {
        closeColorPicker.accessibilityIdentifier = "Editor Text Close Color Picker"
        closeColorPicker.setImage(KanvasEditorDesign.shared.closeGradientImage, for: .normal)
        closeColorPicker.contentMode = .center
        closeColorPicker.backgroundColor = KanvasEditorDesign.shared.buttonInvertedBackgroundColor
        closeColorPicker.layer.cornerRadius = Constants.circularIconSize / 2
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
        let image = KanvasEditorDesign.shared.drawingViewEyeDropperImage?.withRenderingMode(.alwaysTemplate)
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
    
    @objc private func alignmentSelectorTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapAlignmentSelector()
    }
    
    @objc private func fontSelectorTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapFontSelector()
    }
    
    @objc private func highlightSelectorTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapHighlightSelector()
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
    
    // MARK: - MainTextViewDelegate
    
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
        mainTextView.text = nil
    }
    
    /// Opens the keyboard
    func openKeyboard() {
        mainTextView.becomeFirstResponder()
    }
    
    /// Closes the keyboard
    func closeKeyboard() {
        mainTextView.endEditing(true)
    }
    
    /// Moves up the text view and the tools menu
    ///
    /// - Parameter distance: space from original position
    func moveToolsUp(distance: CGFloat) {
        UIView.performWithoutAnimation {
            mainTextViewHeight?.constant = -(Constants.topMargin + Constants.confirmButtonSize + toolsContainer.frame.height + Constants.bottomMargin + distance)
            mainTextView.setNeedsLayout()
            mainTextView.layoutIfNeeded()
        }
        
        toolsContainer.transform = CGAffineTransform(translationX: 0, y: -distance)
        toolsContainer.alpha = 1
        mainTextView.alpha = 1
        topButtonsContainer.alpha = 1
    }
    
    /// Moves the text view and the tools menu to their original position
    func moveToolsDown() {
        topButtonsContainer.alpha = 0
        toolsContainer.alpha = 0
        toolsContainer.transform = .identity
        
        UIView.performWithoutAnimation {
            mainTextView.alpha = 0
            mainTextViewHeight?.constant = -(Constants.topMargin + Constants.confirmButtonSize + toolsContainer.frame.height + Constants.bottomMargin)
            mainTextView.setNeedsLayout()
            mainTextView.layoutIfNeeded()
        }
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        confirmButton.alpha = show ? 1 : 0
    }
    
    // MARK: - Private utilities
    
    /// shows or hides the main text view
    ///
    /// - Parameter show: true to show, false to hide
    private func showTextView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.mainTextView.alpha = show ? 1 : 0
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
