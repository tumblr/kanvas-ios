//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol DrawingViewDelegate: AnyObject {
    
    /// Called when the confirm button is selected
    func didTapConfirmButton()
    
    /// Called when the undo button is selected
    func didTapUndoButton()
    
    /// Called when the erase button is selected
    func didTapEraseButton()
    
    /// Called when the gradient button (that opens the color picker) is selected
    func didTapColorPickerButton()
    
    /// Called when the eye dropper button is selected
    func didTapEyeDropper()
    
    /// Called when the drawing canvas is tapped
    ///
    /// - Parameter recognizer: the tap gesture recognizer
    func didTapDrawingCanvas(recognizer: UITapGestureRecognizer)
    
    /// Called when the drawing canvas is panned
    ///
    /// - Parameter recognizer: the pan gesture recognizer
    func didPanDrawingCanvas(recognizer: UIPanGestureRecognizer)
    
    /// Called when the drawing canvas is long pressed
    ///
    /// - Parameter recognizer: the long press gesture recognizer
    func didLongPressDrawingCanvas(recognizer: UILongPressGestureRecognizer)
    
}

private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    
    // Icon margins
    static let topMargin: CGFloat = 19.5
    static let bottomMargin: CGFloat = 25
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
    
    // Stack Views
    static let stackViewInset: CGFloat = -10
    
    // Top buttons
    static let topButtonSize: CGFloat = KanvasEditorDesign.shared.topButtonSize
    static let topSecondaryButtonSize: CGFloat = KanvasEditorDesign.shared.topSecondaryButtonSize
    static let topButtonSpacing: CGFloat = KanvasEditorDesign.shared.topButtonInterspace
    
    // Selectors
    static let verticalSelectorHeight: CGFloat = 128
    static let verticalSelectorWidth: CGFloat = 34
    static let horizontalSelectorPadding: CGFloat = 14
    static let horizontalSelectorHeight: CGFloat = CircularImageView.size
    
    static let overlayColor = UIColor.black.withAlphaComponent(0.7)
}

/// View for DrawingController
final class DrawingView: IgnoreTouchesView, DrawingCanvasDelegate {
    
    weak var delegate: DrawingViewDelegate?
    
    static let horizontalSelectorPadding = Constants.horizontalSelectorPadding
    static let verticalSelectorWidth = Constants.verticalSelectorWidth
    
    // Drawing views
    let drawingCanvas: DrawingCanvas
    private var drawingCanvasConstraints: FullViewConstraints?
    let temporalImageView: UIImageView
    private var temporalImageViewConstraints: FullViewConstraints?
    
    // Black traslucent overlay used for onboarding
    private let overlay: UIView
    
    // Main containers
    private let topButtonContainer: UIStackView
    private let bottomPanelContainer: UIView
    
    // Top buttons
    private let confirmButton: UIButton
    private let undoButton: UIButton
    private let eraseButton: UIButton
    
    // Bottom panel containers
    private let bottomMenuContainer: UIView
    private let colorPickerContainer: UIView
    
    // Stroke & Texture
    let strokeSelectorContainer: UIView
    let textureSelectorContainer: UIView
    
    // Color picker
    private let colorPickerButton: CircularImageView
    private let closeColorPickerButton: CircularImageView
    private let eyeDropperButton: CircularImageView
    let colorPickerSelectorContainer: UIView
    
    // Color selector
    let colorSelectorContainer: UIView
    var colorSelectorOrigin: CGPoint {
        return colorPickerContainer.convert(eyeDropperButton.center, to: self)
    }
    
    /// Confirm button location expressed in screen coordinates
    var confirmButtonLocation: CGPoint {
        return topButtonContainer.convert(confirmButton.center, to: nil)
    }
    
    // Color collection
    let colorCollection: UIView
    
    init() {
        drawingCanvas = DrawingCanvas()
        temporalImageView = UIImageView()
        topButtonContainer = ExtendedStackView(inset: Constants.stackViewInset)
        bottomPanelContainer = IgnoreTouchesView()
        bottomMenuContainer = IgnoreTouchesView()
        colorPickerContainer = IgnoreTouchesView()
        confirmButton = ExtendedButton(inset: Constants.stackViewInset)
        undoButton = ExtendedButton(inset: Constants.stackViewInset)
        eraseButton = ExtendedButton(inset: Constants.stackViewInset)
        strokeSelectorContainer = IgnoreTouchesView()
        textureSelectorContainer = IgnoreTouchesView()
        closeColorPickerButton = CircularImageView()
        eyeDropperButton = CircularImageView()
        colorCollection = UIView()
        colorPickerButton = CircularImageView()
        colorPickerSelectorContainer = UIView()
        colorSelectorContainer = IgnoreTouchesView()
        overlay = UIView()
        
        super.init(frame: .zero)
        
        clipsToBounds = false
        drawingCanvas.delegate = self
        setUpViews()
    }
    
    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Resize views based on a new rendering rect
    func didRenderRectChange(rect: CGRect) {
        drawingCanvasConstraints?.update(with: rect)
        temporalImageViewConstraints?.update(with: rect)
    }
    
    // MARK: - Layout
    
    private func setUpViews() {
        setUpDrawingTemporalImageView()
        setUpDrawingCanvas()
        setUpTopButtonContainer()
        setUpOverlay()
        setUpTopButtons()
        setUpBottomPanel()
        setUpBottomMenuContainer()
        setUpBottomMenu()
        setUpColorPickerContainer()
        setUpColorPicker()
    }
    
    /// Sets up the color picker menu
    private func setUpColorPicker() {
        setUpColorPickerButton()
        setUpCloseColorPickerButton()
        setUpEyeDropper()
        setUpColorPickerSelectorContainer()
        setUpColorSelectorContainer()
    }
    
    /// Sets up a view where the drawing will be saved temporarily
    private func setUpDrawingTemporalImageView() {
        temporalImageView.accessibilityIdentifier = "Editor Temporal Image View"
        temporalImageView.translatesAutoresizingMaskIntoConstraints = false
        temporalImageView.clipsToBounds = true
        addSubview(temporalImageView)

        temporalImageViewConstraints = FullViewConstraints(
            view: temporalImageView,
            top: temporalImageView.topAnchor.constraint(equalTo: topAnchor),
            bottom: temporalImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leading: temporalImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailing: temporalImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ).activate()
        
        temporalImageView.alpha = 0
    }
    
    private func setUpDrawingCanvas() {
        drawingCanvas.accessibilityIdentifier = "Editor Drawing Canvas"
        drawingCanvas.translatesAutoresizingMaskIntoConstraints = false
        drawingCanvas.clipsToBounds = true
        addSubview(drawingCanvas)

        drawingCanvasConstraints = FullViewConstraints(
            view: drawingCanvas,
            top: drawingCanvas.topAnchor.constraint(equalTo: topAnchor),
            bottom: drawingCanvas.bottomAnchor.constraint(equalTo: bottomAnchor),
            leading: drawingCanvas.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailing: drawingCanvas.trailingAnchor.constraint(equalTo: trailingAnchor)
        ).activate()
        
        let panRecognizer = UIPanGestureRecognizer()
        let longPressRecognizer = UILongPressGestureRecognizer()
        let tapRecognizer = UITapGestureRecognizer()
        
        longPressRecognizer.addTarget(self, action: #selector(drawingCanvasLongPressed(recognizer:)))
        panRecognizer.addTarget(self, action: #selector(drawingCanvasPanned(recognizer:)))
        tapRecognizer.addTarget(self, action: #selector(drawingCanvasTapped(recognizer:)))
        
        longPressRecognizer.cancelsTouchesInView = false
        panRecognizer.cancelsTouchesInView = false
        tapRecognizer.cancelsTouchesInView = false
        
        drawingCanvas.addGestureRecognizer(panRecognizer)
        drawingCanvas.addGestureRecognizer(longPressRecognizer)
        drawingCanvas.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the top buttons stack view
    private func setUpTopButtonContainer() {
        topButtonContainer.accessibilityIdentifier = "Editor Top Button Container"
        topButtonContainer.axis = .vertical
        topButtonContainer.distribution = .equalSpacing
        topButtonContainer.alignment = .center
        topButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topButtonContainer)
        
        let topMargin = Constants.topMargin
        let height = Constants.topButtonSize + Constants.topSecondaryButtonSize * 2 + Constants.topButtonSpacing * 2
        NSLayoutConstraint.activate([
            topButtonContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: topMargin),
            topButtonContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -Constants.rightMargin),
            topButtonContainer.heightAnchor.constraint(equalToConstant: height),
            topButtonContainer.widthAnchor.constraint(equalToConstant: Constants.topButtonSize)
        ])
    }
    
    /// Sets up the translucent black view used for onboarding
    private func setUpOverlay() {
        overlay.accessibilityIdentifier = "Editor Overlay"
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.clipsToBounds = true
        overlay.backgroundColor = Constants.overlayColor
        addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        overlay.alpha = 0
    }
    
    // Adds top buttons to the top buttons container
    private func setUpTopButtons() {
        let checkmarkImage = KanvasEditorDesign.shared.checkmarkImage
        let undoImage = KanvasEditorDesign.shared.drawingViewUndoImage
        let eraserUnselectedImage = KanvasEditorDesign.shared.drawingViewEraserUnselectedImage
        let primaryBackgroundColor = KanvasColors.shared.primaryButtonBackgroundColor
        let secondaryBackgroundColor = KanvasEditorDesign.shared.buttonBackgroundColor
        
        if KanvasEditorDesign.shared.isVerticalMenu {
            confirmButton.setImage(checkmarkImage, for: .normal)
            undoButton.setImage(undoImage, for: .normal)
            eraseButton.setImage(eraserUnselectedImage, for: .normal)
            
            confirmButton.backgroundColor = primaryBackgroundColor
            undoButton.backgroundColor = secondaryBackgroundColor
            eraseButton.backgroundColor = secondaryBackgroundColor
            
            confirmButton.layer.cornerRadius = Constants.topButtonSize / 2
            undoButton.layer.cornerRadius = Constants.topSecondaryButtonSize / 2
            eraseButton.layer.cornerRadius = Constants.topSecondaryButtonSize / 2
        }
        else {
            confirmButton.setBackgroundImage(checkmarkImage, for: .normal)
            undoButton.setBackgroundImage(undoImage, for: .normal)
            eraseButton.setBackgroundImage(eraserUnselectedImage, for: .normal)
        }
        
        let confirmButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(confirmButtonTapped(recognizer:)))
        let undoButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(undoButtonTapped(recognizer:)))
        let eraseButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(eraseButtonTapped(recognizer:)))
        
        confirmButton.addGestureRecognizer(confirmButtonRecognizer)
        undoButton.addGestureRecognizer(undoButtonRecognizer)
        eraseButton.addGestureRecognizer(eraseButtonRecognizer)
        
        topButtonContainer.addArrangedSubview(confirmButton)
        topButtonContainer.addArrangedSubview(undoButton)
        topButtonContainer.addArrangedSubview(eraseButton)
        
        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(equalToConstant: Constants.topButtonSize),
            confirmButton.widthAnchor.constraint(equalToConstant: Constants.topButtonSize),
            undoButton.heightAnchor.constraint(equalToConstant: Constants.topSecondaryButtonSize),
            undoButton.widthAnchor.constraint(equalToConstant: Constants.topSecondaryButtonSize),
            eraseButton.heightAnchor.constraint(equalToConstant: Constants.topSecondaryButtonSize),
            eraseButton.widthAnchor.constraint(equalToConstant: Constants.topSecondaryButtonSize),
        ])
        
        confirmButton.alpha = 0
    }
    
    /// Sets up a view that holds the main menu and also the color picker
    private func setUpBottomPanel() {
        bottomPanelContainer.accessibilityIdentifier = "Editor Bottom Panel Container"
        bottomPanelContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomPanelContainer.clipsToBounds = true
        addSubview(bottomPanelContainer)
        
        NSLayoutConstraint.activate([
            bottomPanelContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            bottomPanelContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bottomPanelContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomMargin),
            bottomPanelContainer.heightAnchor.constraint(equalToConstant: Constants.verticalSelectorHeight),
        ])
    }
    
    /// Sets up the main menu container. It contains the stroke, texture and gradient buttons,
    /// as well as the color colection.
    private func setUpBottomMenuContainer() {
        bottomMenuContainer.accessibilityIdentifier = "Editor Bottom Menu Container"
        bottomMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuContainer.clipsToBounds = true
        
        bottomMenuContainer.add(into: bottomPanelContainer)
    }
    
    /// Sets up components of the main bottom menu
    private func setUpBottomMenu() {
        setUpStrokeSelectorContainer()
        setUpTextureSelectorContainer()
        setUpColorCollection()
    }
    
    // MARK: Layout: Stroke selector
    
    private func setUpStrokeSelectorContainer() {
        strokeSelectorContainer.accessibilityIdentifier = "Editor Stroke Selector Container"
        strokeSelectorContainer.clipsToBounds = false
        strokeSelectorContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuContainer.addSubview(strokeSelectorContainer)
        
        NSLayoutConstraint.activate([
            strokeSelectorContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leftMargin),
            strokeSelectorContainer.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            strokeSelectorContainer.heightAnchor.constraint(equalToConstant: Constants.verticalSelectorHeight),
            strokeSelectorContainer.widthAnchor.constraint(equalToConstant: Constants.verticalSelectorWidth),
        ])
    }
    
    // MARK: Layout: Texture selector
    
    private func setUpTextureSelectorContainer() {
        textureSelectorContainer.accessibilityIdentifier = "Editor Texture Selector Container"
        textureSelectorContainer.clipsToBounds = false
        textureSelectorContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuContainer.addSubview(textureSelectorContainer)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = Constants.leftMargin + cellSpace
        NSLayoutConstraint.activate([
            textureSelectorContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            textureSelectorContainer.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            textureSelectorContainer.heightAnchor.constraint(equalToConstant: TextureSelectorView.selectorHeight),
            textureSelectorContainer.widthAnchor.constraint(equalToConstant: TextureSelectorView.selectorWidth),
        ])
    }
    
    // MARK: - Layout: Color picker
    
    /// Sets up the gradient button that opens the color picker menu
    private func setUpColorPickerButton() {
        colorPickerButton.image = KanvasImages.gradientImage
        bottomMenuContainer.addSubview(colorPickerButton)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = Constants.leftMargin + cellSpace * 2
        NSLayoutConstraint.activate([
            colorPickerButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            colorPickerButton.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            colorPickerButton.heightAnchor.constraint(equalToConstant: CircularImageView.size),
            colorPickerButton.widthAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(colorPickerButtonTapped(recognizer:)))
        colorPickerButton.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the container that holds the close button, eyedropper, color picker gradient
    private func setUpColorPickerContainer() {
        colorPickerContainer.accessibilityIdentifier = "Editor Color Picker Container"
        colorPickerContainer.translatesAutoresizingMaskIntoConstraints = false
        colorPickerContainer.clipsToBounds = true
        
        colorPickerContainer.add(into: bottomPanelContainer)
        
        colorPickerContainer.alpha = 0
    }
    
    /// Sets up the cross button to close the color picker menu
    private func setUpCloseColorPickerButton() {
        closeColorPickerButton.image = KanvasEditorDesign.shared.closeGradientImage
        closeColorPickerButton.contentMode = .center
        closeColorPickerButton.backgroundColor = KanvasEditorDesign.shared.buttonInvertedBackgroundColor
        closeColorPickerButton.accessibilityIdentifier = "Editor Close Color Picker Button"
        colorPickerContainer.addSubview(closeColorPickerButton)
        
        NSLayoutConstraint.activate([
            closeColorPickerButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Constants.leftMargin),
            closeColorPickerButton.bottomAnchor.constraint(equalTo: colorPickerContainer.bottomAnchor),
            closeColorPickerButton.heightAnchor.constraint(equalToConstant: CircularImageView.size),
            closeColorPickerButton.widthAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(closeColorPickerButtonTapped(recognizer:)))
        closeColorPickerButton.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the eye dropper button in the color picker menu
    private func setUpEyeDropper() {
        eyeDropperButton.image = KanvasEditorDesign.shared.drawingViewEyeDropperImage?.withRenderingMode(.alwaysTemplate)
        eyeDropperButton.contentMode = .center
        eyeDropperButton.accessibilityIdentifier = "Editor Eye Dropper Button"
        colorPickerContainer.addSubview(eyeDropperButton)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = Constants.leftMargin + cellSpace
        NSLayoutConstraint.activate([
            eyeDropperButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            eyeDropperButton.bottomAnchor.constraint(equalTo: colorPickerContainer.bottomAnchor),
            eyeDropperButton.heightAnchor.constraint(equalToConstant: CircularImageView.size),
            eyeDropperButton.widthAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(eyeDropperTapped(recognizer:)))
        eyeDropperButton.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the horizontal gradient that allows to pick a color
    private func setUpColorPickerSelectorContainer() {
        colorPickerSelectorContainer.backgroundColor = .clear
        colorPickerSelectorContainer.accessibilityIdentifier = "Editor Color Picker Selector Container"
        colorPickerSelectorContainer.clipsToBounds = false
        colorPickerSelectorContainer.translatesAutoresizingMaskIntoConstraints = false
        colorPickerContainer.addSubview(colorPickerSelectorContainer)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = Constants.leftMargin + cellSpace * 2
        NSLayoutConstraint.activate([
            colorPickerSelectorContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            colorPickerSelectorContainer.trailingAnchor.constraint(equalTo: colorPickerContainer.trailingAnchor, constant: -Constants.rightMargin),
            colorPickerSelectorContainer.bottomAnchor.constraint(equalTo: colorPickerContainer.bottomAnchor),
            colorPickerSelectorContainer.heightAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
    }
    
    private func setUpColorSelectorContainer() {
        colorSelectorContainer.backgroundColor = .clear
        colorSelectorContainer.accessibilityIdentifier = "Editor Color Selector Container"
        colorSelectorContainer.clipsToBounds = false
        colorSelectorContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorSelectorContainer)
        
        NSLayoutConstraint.activate([
            colorSelectorContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorSelectorContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorSelectorContainer.topAnchor.constraint(equalTo: topAnchor),
            colorSelectorContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    /// Sets up the color collection that contains the dominant colors as well as the last colors selected
    private func setUpColorCollection() {
        colorCollection.backgroundColor = .clear
        colorCollection.accessibilityIdentifier = "Color Collection Container"
        colorCollection.clipsToBounds = false
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuContainer.addSubview(colorCollection)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = Constants.leftMargin + cellSpace * 3 - CircularImageView.padding
        NSLayoutConstraint.activate([
            colorCollection.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            colorCollection.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            colorCollection.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            colorCollection.heightAnchor.constraint(equalToConstant: CircularImageView.size)
        ])
    }
    
    // MARK: - Gesture recognizers
    
    @objc func confirmButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapConfirmButton()
    }
    
    @objc func undoButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapUndoButton()
    }
    
    @objc func eraseButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapEraseButton()
    }
    
    @objc func colorPickerButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapColorPickerButton()
    }
    
    @objc func closeColorPickerButtonTapped(recognizer: UITapGestureRecognizer) {
        showColorPickerContainer(false)
        showBottomMenu(true)
    }
    
    @objc func eyeDropperTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapEyeDropper()
    }
    
    @objc func drawingCanvasTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapDrawingCanvas(recognizer: recognizer)
    }
    
    @objc func drawingCanvasPanned(recognizer: UIPanGestureRecognizer) {
        delegate?.didPanDrawingCanvas(recognizer: recognizer)
    }
    
    @objc func drawingCanvasLongPressed(recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPressDrawingCanvas(recognizer: recognizer)
    }
    
    // MARK: - View animations
    
    /// toggles the erase icon (selected or unselected)
    func changeEraseIcon(selected: Bool) {
        let image: UIImage?
        let backgroundColor: UIColor
        
        if selected {
            image = KanvasEditorDesign.shared.drawingViewEraserSelectedImage
            backgroundColor = KanvasEditorDesign.shared.buttonInvertedBackgroundColor
        }
        else {
            image = KanvasEditorDesign.shared.drawingViewEraserUnselectedImage
            backgroundColor = KanvasEditorDesign.shared.buttonBackgroundColor
        }
        
        UIView.transition(with: eraseButton, duration: Constants.animationDuration, options: .transitionCrossDissolve, animations: {
            if KanvasEditorDesign.shared.isVerticalMenu {
                self.eraseButton.setImage(image, for: .normal)
                self.eraseButton.backgroundColor = backgroundColor
            }
            else {
                self.eraseButton.setBackgroundImage(image, for: .normal)
            }
            
        }, completion: nil)
    }
    
    /// shows or hides the bottom panel (it includes the buttons menu and the color picker)
    ///
    /// - Parameter show: true to show, false to hide
    func showBottomPanel(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.bottomPanelContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the color picker and its buttons
    ///
    /// - Parameter show: true to show, false to hide
    func showColorPickerContainer(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.colorPickerContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the stroke, texture, gradient, and recently-used color buttons
    ///
    /// - Parameter show: true to show, false to hide
    func showBottomMenu(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.bottomMenuContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the erase and undo buttons
    ///
    /// - Parameter show: true to show, false to hide
    func showTopButtons(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.topButtonContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the overlay of the stroke selector
    ///
    /// - Parameter show: true to show, false to hide
    /// - Parameter animate: whether the UI update is animated
    func showOverlay(_ show: Bool, animate: Bool = true) {
        if animate {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.overlay.alpha = show ? 1 : 0
            }
        }
        else {
            self.overlay.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the drawing canvas
    ///
    /// - Parameter show: true to show, false to hide
    func showCanvas(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.drawingCanvas.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides all the menus
    ///
    /// - Parameter show: true to show, false to hide
    private func showTools(show: Bool) {
        showTopButtons(show)
        showBottomPanel(show)
    }
    
    // MARK: - Public interface
    
    /// enables or disables user interation on the view
    ///
    /// - Parameter enable: true to enable, false to disable
    func enableView(_ enable: Bool) {
        isUserInteractionEnabled = enable
    }
    
    /// enables or disables drawing on the drawing canvas
    ///
    /// - Parameter enable: true to enable, false to disable
    func enableDrawingCanvas(_ enable: Bool) {
        drawingCanvas.isUserInteractionEnabled = enable
    }
    
    /// Sets a new color for the eye dropper button background
    ///
    /// - Parameter color: new color for the eye dropper
    func setEyeDropperColor(_ color: UIColor) {
        eyeDropperButton.tintColor = color.matchingColor()
        eyeDropperButton.backgroundColor = color
    }
    
    // MARK: - DrawingCanvasDelegate
    
    func didBeginTouches() {
        showTools(show: false)
    }
    
    func didEndTouches() {
        showTools(show: true)
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        confirmButton.alpha = show ? 1 : 0
    }
}
