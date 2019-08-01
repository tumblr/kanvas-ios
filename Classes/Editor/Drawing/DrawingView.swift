//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import SharedUI

protocol DrawingViewDelegate: class {
    
    /// Called after the color selecter tooltip is dismissed
    func didDismissColorSelecterTooltip()
    
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
    
    /// Called when the color selecter is panned
    ///
    /// - Parameter recognizer: the pan gesture recognizer
    func didPanColorSelecter(recognizer: UIPanGestureRecognizer)
    
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

private struct DrawingViewConstants {
    static let animationDuration: TimeInterval = 0.25
    
    // Icon margins
    static let topMargin: CGFloat = 19.5
    static let bottomMargin: CGFloat = 25
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
    
    // Stack Views
    static let stackViewInset: CGFloat = -10
    
    // Top buttons
    static let topButtonSize: CGFloat = 36
    static let topButtonSpacing: CGFloat = 30
    
    // Selectors
    static let verticalSelectorHeight: CGFloat = 128
    static let verticalSelectorWidth: CGFloat = 34
    static let horizontalSelectorPadding: CGFloat = 14
    static let horizontalSelectorHeight: CGFloat = CircularImageView.size
    
    // Color selecter
    static let colorSelecterSize: CGFloat = 80
    static let dropHeight: CGFloat = 55
    static let dropWidth: CGFloat = 39
    static let dropPadding: CGFloat = 18
    static let colorSelecterAlpha: CGFloat = 0.65
    static let overlayColor = UIColor.black.withAlphaComponent(0.7)
    
    // Tooltip
    static let tooltipForegroundColor: UIColor = .white
    static let tooltipBackgroundColor: UIColor = .tumblrBrightBlue
    static let tooltipArrowPosition: EasyTipView.ArrowPosition = .bottom
    static let tooltipCornerRadius: CGFloat = 6
    static let tooltipArrowWidth: CGFloat = 11
    static let tooltipMargin: CGFloat = 12
    static let tooltipFont: UIFont = .favoritTumblr85(fontSize: 14)
    static let tooltipVerticalTextInset: CGFloat = 13
    static let tooltipHorizontalTextInset: CGFloat = 16
}

/// View for DrawingController
final class DrawingView: IgnoreTouchesView, DrawingCanvasDelegate {
    
    weak var delegate: DrawingViewDelegate?
    
    static let horizontalSelectorPadding = DrawingViewConstants.horizontalSelectorPadding
    static let verticalSelectorWidth = DrawingViewConstants.verticalSelectorWidth
    
    // Drawing views
    let drawingCanvas: DrawingCanvas
    let temporalImageView: UIImageView
    
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
    
    // Color selecter
    private let colorSelecter: CircularImageView
    private var tooltip: EasyTipView?
    private let upperDrop: UIImageView
    private let lowerDrop: UIImageView
    
    // Color collection
    let colorCollection: UIView
    
    init() {
        drawingCanvas = DrawingCanvas()
        temporalImageView = UIImageView()
        topButtonContainer = ExtendedStackView(inset: DrawingViewConstants.stackViewInset)
        bottomPanelContainer = IgnoreTouchesView()
        bottomMenuContainer = IgnoreTouchesView()
        colorPickerContainer = IgnoreTouchesView()
        confirmButton = ExtendedButton(inset: DrawingViewConstants.stackViewInset)
        undoButton = ExtendedButton(inset: DrawingViewConstants.stackViewInset)
        eraseButton = ExtendedButton(inset: DrawingViewConstants.stackViewInset)
        strokeSelectorContainer = IgnoreTouchesView()
        textureSelectorContainer = IgnoreTouchesView()
        closeColorPickerButton = CircularImageView()
        eyeDropperButton = CircularImageView()
        colorCollection = UIView()
        colorPickerButton = CircularImageView()
        colorPickerSelectorContainer = UIView()
        colorSelecter = CircularImageView()
        upperDrop = UIImageView()
        lowerDrop = UIImageView()
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
        setUpColorSelecter()
        setUpColorSelecterDrop()
        setUpTooltip()
    }
    
    /// Sets up a view where the drawing will be saved temporarily
    private func setUpDrawingTemporalImageView() {
        temporalImageView.accessibilityIdentifier = "Editor Temporal Image View"
        temporalImageView.translatesAutoresizingMaskIntoConstraints = false
        temporalImageView.clipsToBounds = true
        addSubview(temporalImageView)
        
        NSLayoutConstraint.activate([
            temporalImageView.topAnchor.constraint(equalTo: topAnchor),
            temporalImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            temporalImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            temporalImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        temporalImageView.alpha = 0
    }
    
    private func setUpDrawingCanvas() {
        drawingCanvas.accessibilityIdentifier = "Editor Drawing Canvas"
        drawingCanvas.translatesAutoresizingMaskIntoConstraints = false
        drawingCanvas.clipsToBounds = true
        addSubview(drawingCanvas)
        
        NSLayoutConstraint.activate([
            drawingCanvas.topAnchor.constraint(equalTo: topAnchor),
            drawingCanvas.bottomAnchor.constraint(equalTo: bottomAnchor),
            drawingCanvas.leadingAnchor.constraint(equalTo: leadingAnchor),
            drawingCanvas.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
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
        
        let topMargin = DrawingViewConstants.topMargin
        let height = DrawingViewConstants.topButtonSize * 3 + DrawingViewConstants.topButtonSpacing * 2
        NSLayoutConstraint.activate([
            topButtonContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: topMargin),
            topButtonContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -DrawingViewConstants.rightMargin),
            topButtonContainer.heightAnchor.constraint(equalToConstant: height),
            topButtonContainer.widthAnchor.constraint(equalToConstant: DrawingViewConstants.topButtonSize)
        ])
    }
    
    /// Sets up the translucent black view used for onboarding
    private func setUpOverlay() {
        overlay.accessibilityIdentifier = "Editor Overlay"
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.clipsToBounds = true
        overlay.backgroundColor = DrawingViewConstants.overlayColor
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
        confirmButton.setBackgroundImage(KanvasCameraImages.editorConfirmImage, for: .normal)
        undoButton.setBackgroundImage(KanvasCameraImages.undoImage, for: .normal)
        eraseButton.setBackgroundImage(KanvasCameraImages.eraserUnselectedImage, for: .normal)
        
        let confirmButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(confirmButtonTapped(recognizer:)))
        let undoButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(undoButtonTapped(recognizer:)))
        let eraseButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(eraseButtonTapped(recognizer:)))
        
        confirmButton.addGestureRecognizer(confirmButtonRecognizer)
        undoButton.addGestureRecognizer(undoButtonRecognizer)
        eraseButton.addGestureRecognizer(eraseButtonRecognizer)
        
        topButtonContainer.addArrangedSubview(confirmButton)
        topButtonContainer.addArrangedSubview(undoButton)
        topButtonContainer.addArrangedSubview(eraseButton)
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
            bottomPanelContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -DrawingViewConstants.bottomMargin),
            bottomPanelContainer.heightAnchor.constraint(equalToConstant: DrawingViewConstants.verticalSelectorHeight),
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
            strokeSelectorContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: DrawingViewConstants.leftMargin),
            strokeSelectorContainer.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            strokeSelectorContainer.heightAnchor.constraint(equalToConstant: DrawingViewConstants.verticalSelectorHeight),
            strokeSelectorContainer.widthAnchor.constraint(equalToConstant: DrawingViewConstants.verticalSelectorWidth),
        ])
    }
    
    // MARK: Layout: Texture selector
    
    private func setUpTextureSelectorContainer() {
        textureSelectorContainer.accessibilityIdentifier = "Editor Texture Selector Container"
        textureSelectorContainer.clipsToBounds = false
        textureSelectorContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuContainer.addSubview(textureSelectorContainer)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = DrawingViewConstants.leftMargin + cellSpace
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
        colorPickerButton.image = KanvasCameraImages.gradientImage
        bottomMenuContainer.addSubview(colorPickerButton)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = DrawingViewConstants.leftMargin + cellSpace * 2
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
        closeColorPickerButton.image = KanvasCameraImages.closeGradientImage
        closeColorPickerButton.accessibilityIdentifier = "Editor Close Color Picker Button"
        colorPickerContainer.addSubview(closeColorPickerButton)
        
        NSLayoutConstraint.activate([
            closeColorPickerButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: DrawingViewConstants.leftMargin),
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
        eyeDropperButton.image = KanvasCameraImages.eyeDropperImage?.withRenderingMode(.alwaysTemplate)
        eyeDropperButton.tintColor = .white
        eyeDropperButton.contentMode = .center
        eyeDropperButton.backgroundColor = .tumblrBrightBlue
        eyeDropperButton.accessibilityIdentifier = "Editor Eye Dropper Button"
        colorPickerContainer.addSubview(eyeDropperButton)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = DrawingViewConstants.leftMargin + cellSpace
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
        let margin = DrawingViewConstants.leftMargin + cellSpace * 2
        NSLayoutConstraint.activate([
            colorPickerSelectorContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            colorPickerSelectorContainer.trailingAnchor.constraint(equalTo: colorPickerContainer.trailingAnchor, constant: -DrawingViewConstants.rightMargin),
            colorPickerSelectorContainer.bottomAnchor.constraint(equalTo: colorPickerContainer.bottomAnchor),
            colorPickerSelectorContainer.heightAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
    }
    
    /// Sets up the draggable circle that is shown when the eyedropper is pressed
    private func setUpColorSelecter() {
        colorSelecter.backgroundColor = UIColor.black.withAlphaComponent(DrawingViewConstants.colorSelecterAlpha)
        colorSelecter.layer.cornerRadius = DrawingViewConstants.colorSelecterSize / 2
        colorSelecter.accessibilityIdentifier = "Editor Color Selecter"
        addSubview(colorSelecter)
        
        NSLayoutConstraint.activate([
            colorSelecter.centerXAnchor.constraint(equalTo: eyeDropperButton.centerXAnchor),
            colorSelecter.centerYAnchor.constraint(equalTo: eyeDropperButton.centerYAnchor),
            colorSelecter.heightAnchor.constraint(equalToConstant: DrawingViewConstants.colorSelecterSize),
            colorSelecter.widthAnchor.constraint(equalToConstant: DrawingViewConstants.colorSelecterSize),
        ])
        
        colorSelecter.alpha = 0
        
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(colorSelecterPanned(recognizer:)))
        colorSelecter.addGestureRecognizer(panRecognizer)
    }
    
    private func setUpColorSelecterDrop() {
        setUpColorSelecterUpperDrop()
        setUpColorSelecterLowerDrop()
    }
    
    private func setUpColorSelecterUpperDrop() {
        upperDrop.accessibilityIdentifier = "Editor Color Selecter Upper Drop"
        upperDrop.image = KanvasCameraImages.dropImage?.withRenderingMode(.alwaysTemplate)
        upperDrop.translatesAutoresizingMaskIntoConstraints = false
        upperDrop.clipsToBounds = true
        addSubview(upperDrop)
        
        let verticalMargin = DrawingViewConstants.dropPadding
        NSLayoutConstraint.activate([
            upperDrop.bottomAnchor.constraint(equalTo: colorSelecter.topAnchor, constant: -verticalMargin),
            upperDrop.centerXAnchor.constraint(equalTo: colorSelecter.centerXAnchor),
            upperDrop.heightAnchor.constraint(equalToConstant: DrawingViewConstants.dropHeight),
            upperDrop.widthAnchor.constraint(equalToConstant: DrawingViewConstants.dropWidth),
        ])
        
        upperDrop.alpha = 0
    }
    
    private func setUpColorSelecterLowerDrop() {
        lowerDrop.accessibilityIdentifier = "Editor Color Selecter Lower Drop"
        lowerDrop.image = KanvasCameraImages.dropImage?.withRenderingMode(.alwaysTemplate)
        lowerDrop.transform = CGAffineTransform(rotationAngle: .pi)
        lowerDrop.translatesAutoresizingMaskIntoConstraints = false
        lowerDrop.clipsToBounds = true
        addSubview(lowerDrop)
        
        let verticalMargin = DrawingViewConstants.dropPadding
        NSLayoutConstraint.activate([
            lowerDrop.topAnchor.constraint(equalTo: colorSelecter.bottomAnchor, constant: verticalMargin),
            lowerDrop.centerXAnchor.constraint(equalTo: colorSelecter.centerXAnchor),
            lowerDrop.heightAnchor.constraint(equalToConstant: DrawingViewConstants.dropHeight),
            lowerDrop.widthAnchor.constraint(equalToConstant: DrawingViewConstants.dropWidth),
        ])
        
        lowerDrop.alpha = 0
    }
    
    /// Sets up the color collection that contains the dominant colors as well as the last colors selected
    private func setUpColorCollection() {
        colorCollection.backgroundColor = .clear
        colorCollection.accessibilityIdentifier = "Color Collection Container"
        colorCollection.clipsToBounds = false
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuContainer.addSubview(colorCollection)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = DrawingViewConstants.leftMargin + cellSpace * 3 - CircularImageView.padding
        NSLayoutConstraint.activate([
            colorCollection.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            colorCollection.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            colorCollection.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            colorCollection.heightAnchor.constraint(equalToConstant: CircularImageView.size)
        ])
    }
    
    /// Sets up the tooltip that is shown on top of the color selecter
    private func setUpTooltip() {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.foregroundColor = DrawingViewConstants.tooltipForegroundColor
        preferences.drawing.backgroundColor = DrawingViewConstants.tooltipBackgroundColor
        preferences.drawing.arrowPosition = DrawingViewConstants.tooltipArrowPosition
        preferences.drawing.cornerRadius = DrawingViewConstants.tooltipCornerRadius
        preferences.drawing.arrowWidth = DrawingViewConstants.tooltipArrowWidth
        preferences.positioning.margin = DrawingViewConstants.tooltipMargin
        preferences.drawing.font = DrawingViewConstants.tooltipFont
        preferences.positioning.textVInset = DrawingViewConstants.tooltipVerticalTextInset
        preferences.positioning.textHInset = DrawingViewConstants.tooltipHorizontalTextInset
        
        let text = NSLocalizedString("Drag to select color", comment: "Color selecter tooltip for the Camera")
        tooltip = EasyTipView(text: text, preferences: preferences)
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
    
    @objc func colorSelecterPanned(recognizer: UIPanGestureRecognizer) {
        delegate?.didPanColorSelecter(recognizer: recognizer)
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
    
    // MARK: - Private utilities
    
    /// Changes upper drop location on screen
    ///
    /// - Parameter point: the new location
    private func moveUpperDrop(to point: CGPoint) {
        upperDrop.center = point
    }
    
    /// Changes lower drop location on screen
    ///
    /// - Parameter point: the new location
    private func moveLowerDrop(to point: CGPoint) {
        lowerDrop.center = point
    }
    
    // MARK: - View animations
    
    /// toggles the erase icon (selected or unselected)
    func changeEraseIcon(selected: Bool) {
        let image = selected ? KanvasCameraImages.eraserSelectedImage : KanvasCameraImages.eraserUnselectedImage
        
        UIView.transition(with: eraseButton, duration: DrawingViewConstants.animationDuration, options: .transitionCrossDissolve, animations: {
            self.eraseButton.setBackgroundImage(image, for: .normal)
        }, completion: nil)
    }
    
    /// shows or hides the bottom panel (it includes the buttons menu and the color picker)
    ///
    /// - Parameter show: true to show, false to hide
    func showBottomPanel(_ show: Bool) {
        UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
            self.bottomPanelContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the color picker and its buttons
    ///
    /// - Parameter show: true to show, false to hide
    func showColorPickerContainer(_ show: Bool) {
        UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
            self.colorPickerContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the stroke, texture, gradient, and recently-used color buttons
    ///
    /// - Parameter show: true to show, false to hide
    func showBottomMenu(_ show: Bool) {
        UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
            self.bottomMenuContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the erase and undo buttons
    ///
    /// - Parameter show: true to show, false to hide
    func showTopButtons(_ show: Bool) {
        UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
            self.topButtonContainer.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showColorSelecter(_ show: Bool) {
        UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
            self.colorSelecter.alpha = show ? 1 : 0
            self.colorSelecter.transform = .identity
            self.upperDrop.alpha = show ? 1 : 0
            self.lowerDrop.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides all the menus
    ///
    /// - Parameter show: true to show, false to hide
    private func showTools(show: Bool) {
        showTopButtons(show)
        showBottomPanel(show)
    }
    
    /// shows or hides the overlay of the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    /// - Parameter animate: whether the UI update is animated
    func showOverlay(_ show: Bool, animate: Bool = true) {
        if animate {
            UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
                self.overlay.alpha = show ? 1 : 0
            }
        }
        else {
            self.overlay.alpha = show ? 1 : 0
        }
    }
    
    /// shows or hides the tooltip above color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showTooltip(_ show: Bool) {
        if show {
            tooltip?.show(animated: true, forView: colorSelecter, withinSuperview: self)
        }
        else {
            UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
                self.tooltip?.removeFromSuperview()
                self.tooltip?.dismiss()
            }
            delegate?.didDismissColorSelecterTooltip()
        }
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
        eyeDropperButton.backgroundColor = color
    }
    
    /// Sets a new color for the color selecter background
    ///
    /// - Parameter color: new color for the color selecter
    func setColorSelecterColor(_ color: UIColor) {
        colorSelecter.backgroundColor = color.withAlphaComponent(DrawingViewConstants.colorSelecterAlpha)
        upperDrop.tintColor = color
        lowerDrop.tintColor = color
    }
    
    /// Changes color selector location on screen
    ///
    /// - Parameter point: the new location
    func moveColorSelecter(to point: CGPoint) {
        colorSelecter.center = point
        
        let offset = DrawingViewConstants.dropPadding + (DrawingViewConstants.colorSelecterSize + DrawingViewConstants.dropHeight) / 2
        
        let upperDropLocation = CGPoint(x: point.x, y: point.y - offset)
        let lowerDropLocation = CGPoint(x: point.x, y: point.y + offset)
        moveUpperDrop(to: upperDropLocation)
        moveLowerDrop(to: lowerDropLocation)
        
        let topPoint = CGPoint(x: upperDrop.center.x, y: upperDrop.center.y - upperDrop.frame.height / 2)
        let upperDropVisible = topPoint.y > 0
        upperDrop.alpha = upperDropVisible ? 1 : 0
        lowerDrop.alpha = upperDropVisible ? 0 : 1
    }
    
    /// Applies a transformation to the color selecter
    ///
    /// - Parameter transform: the transformation to apply
    func transformColorSelecter(_ transform: CGAffineTransform) {
        colorSelecter.transform = transform
    }
    
    /// Calculates the color selecter initial location expressed in screen coordinates
    ///
    /// - Returns: the initial location for the color selecter
    func getColorSelecterInitialLocation() -> CGPoint {
        return colorPickerContainer.convert(eyeDropperButton.center, to: self)
    }
    
    
    // MARK: - DrawingCanvasDelegate
    
    func didBeginTouches() {
        showTools(show: false)
    }
    
    func didEndTouches() {
        showTools(show: true)
    }
}
