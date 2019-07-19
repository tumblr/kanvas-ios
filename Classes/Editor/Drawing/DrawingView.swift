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
    
    /// Called when the stroke button is held
    ///
    /// - Parameter recognizer: the long press gesture recognizer
    func didLongPressStrokeButton(recognizer: UILongPressGestureRecognizer)
    
    /// Called when the texture button is selected
    func didTapTextureButton()
    
    /// Called when the pencil texture is selected
    func didTapPencilButton()
    
    /// Called when the sharpie texture is selected
    func didTapSharpieButton()
    
    /// Called when the marker texture is selected
    func didTapMarkerButton()
    
    /// Called when the gradient button (that opens the color picker) is selected
    func didTapColorPickerButton()
    
    /// Called when the cross button (that closes the color picker) is selected
    func didTapCloseColorPickerButton()
    
    /// Called when the eye dropper button is selected
    func didTapEyeDropper()
    
    /// Called when the color picker gradient is tapped
    ///
    /// - Parameter recognizer: the tap gesture recognizer
    func didTapColorPickerSelector(recognizer: UITapGestureRecognizer)
    
    /// Called when the color picker gradient is panned
    ///
    /// - Parameter recognizer: the pan gesture recognizer
    func didPanColorPickerSelector(recognizer: UIPanGestureRecognizer)
    
    /// Called when the color picker gradient is long pressed
    ///
    /// - Parameter recognizer: the long press gesture recognizer
    func didLongPressColorPickerSelector(recognizer: UILongPressGestureRecognizer)
    
    /// Called when the color selecter is panned
    ///
    /// - Parameter recognizer: the pan gesture recognizer
    func didPanColorSelecter(recognizer: UIPanGestureRecognizer)
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
    
    // Stroke
    static let strokeCircleMinSize: CGFloat = 11
    static let strokeCircleMaxSize: CGFloat = 18
    static let strokeSelectorPadding: CGFloat = 11
    
    // Texture
    static let textureOptionSize = CircularImageView.size
    static let textureSelectorPadding: CGFloat = 7
    
    // Color picker
    static let colorPickerCircleSize: CGFloat = 18
    
    // Color selecter
    static let colorSelecterSize: CGFloat = 80
    static let colorSelecterAlpha: CGFloat = 0.65
    static let overlayColor = UIColor.black.withAlphaComponent(0.7)
    
    // Color picker gradient
    static let colorPickerColorLocations: [NSNumber] = [0.0, 0.05, 0.2, 0.4, 0.64, 0.82, 0.95, 1.0]
    
    static let colorPickerColors = [UIColor.tumblrBrightBlue,
                                    UIColor.tumblrBrightBlue,
                                    UIColor.tumblrBrightPurple,
                                    UIColor.tumblrBrightPink,
                                    UIColor.tumblrBrightRed,
                                    UIColor.tumblrBrightYellow,
                                    UIColor.tumblrBrightGreen,
                                    UIColor.tumblrBrightGreen,]
    
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
    static let colorSelecterAlpha = DrawingViewConstants.colorSelecterAlpha
    static let strokeCircleMinSize = DrawingViewConstants.strokeCircleMinSize
    static let strokeCircleMaxSize = DrawingViewConstants.strokeCircleMaxSize
    
    // Drawing views
    let drawingCanvas: DrawingCanvas
    let temporalImageView: UIImageView
    
    // Black traslucent overlay used for onboarding
    let overlay: UIView
    
    // Main containers
    private let topButtonContainer: UIStackView
    private let bottomPanelContainer: UIView
    
    // Top buttons
    let confirmButton: UIButton
    let undoButton: UIButton
    let eraseButton: UIButton
    
    // Bottom panel containers
    private let bottomMenuContainer: UIView
    let colorPickerContainer: UIView
    
    // Stroke
    let strokeButton: CircularImageView
    let strokeButtonCircle: UIImageView
    let strokeSelectorBackground: CircularImageView
    let strokeSelectorPannableArea: UIView
    let strokeSelectorCircle: UIImageView
    
    // Texture
    let textureButton: CircularImageView
    let textureSelectorBackground: CircularImageView
    let textureOptionsContainer: UIStackView
    let sharpieButton: UIButton
    let pencilButton: UIButton
    let markerButton: UIButton
    
    // Color picker
    let colorPickerButton: CircularImageView
    let closeColorPickerButton: CircularImageView
    
    // Color picker gradient
    let colorPickerSelectorBackground: CircularImageView
    let colorPickerSelectorPannableArea: UIView
    let colorPickerGradient: CAGradientLayer
    
    // Eye Dropper
    let eyeDropperButton: CircularImageView
    
    // Color selecter
    let colorSelecter: CircularImageView
    private var tooltip: EasyTipView?
    
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
        strokeButton = CircularImageView()
        strokeSelectorBackground = CircularImageView()
        strokeSelectorPannableArea = UIView()
        strokeButtonCircle = UIImageView()
        strokeSelectorCircle = UIImageView()
        textureButton = CircularImageView()
        textureSelectorBackground = CircularImageView()
        closeColorPickerButton = CircularImageView()
        eyeDropperButton = CircularImageView()
        colorCollection = UIView()
        colorPickerButton = CircularImageView()
        colorPickerSelectorBackground = CircularImageView()
        textureOptionsContainer = ExtendedStackView(inset: DrawingViewConstants.stackViewInset)
        sharpieButton = ExtendedButton(inset: DrawingViewConstants.stackViewInset)
        pencilButton = ExtendedButton(inset: DrawingViewConstants.stackViewInset)
        markerButton = ExtendedButton(inset: DrawingViewConstants.stackViewInset)
        colorPickerSelectorPannableArea = UIView()
        colorPickerGradient = CAGradientLayer()
        colorSelecter = CircularImageView()
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
        setUpColorPickerSelector()
        setUpColorPickerSelectorPannableArea()
        setUpColorSelecter()
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
        setUpStrokeButton()
        setUpStrokeButtonCircle()
        setUpStrokeSelectorBackground()
        setUpStrokeSelectorPannableArea()
        setUpStrokeSelectorCircle()
        
        setUpTextureButton()
        setUpTextureSelectorBackground()
        setUpTextureOptionContainer()
        setUpTextureOptions()
        
        setUpColorCollection()
    }
    
    // MARK: Layout: Stroke selector
    
    /// Sets up the stroke button on the main menu
    private func setUpStrokeButton() {
        strokeButton.accessibilityIdentifier = "Editor Stroke Button"
        strokeButton.backgroundColor = .white
        strokeButton.contentMode = .center
        bottomMenuContainer.addSubview(strokeButton)
        
        NSLayoutConstraint.activate([
            strokeButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: DrawingViewConstants.leftMargin),
            strokeButton.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            strokeButton.heightAnchor.constraint(equalToConstant: CircularImageView.size),
            strokeButton.widthAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
        
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: #selector(strokeButtonLongPressed(recognizer:)))
        longPressRecognizer.minimumPressDuration = 0
        strokeButton.addGestureRecognizer(longPressRecognizer)
    }
    
    /// Sets up the black circle inside the stroke button
    private func setUpStrokeButtonCircle() {
        strokeButtonCircle.accessibilityIdentifier = "Editor Stroke Button Circle"
        strokeButtonCircle.image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        strokeButtonCircle.tintColor = .black
        strokeButtonCircle.isUserInteractionEnabled = true
        strokeButtonCircle.translatesAutoresizingMaskIntoConstraints = false
        strokeButtonCircle.contentMode = .scaleAspectFill
        strokeButtonCircle.clipsToBounds = true
        strokeButton.addSubview(strokeButtonCircle)
        
        NSLayoutConstraint.activate([
            strokeButtonCircle.heightAnchor.constraint(equalToConstant: DrawingViewConstants.strokeCircleMinSize),
            strokeButtonCircle.widthAnchor.constraint(equalToConstant: DrawingViewConstants.strokeCircleMinSize),
            strokeButtonCircle.centerXAnchor.constraint(equalTo: strokeButton.centerXAnchor),
            strokeButtonCircle.centerYAnchor.constraint(equalTo: strokeButton.centerYAnchor),
        ])
    }
    
    /// Sets up the rounded white background for the stroke selector
    private func setUpStrokeSelectorBackground() {
        strokeSelectorBackground.accessibilityIdentifier = "Editor Stroke Selector Background"
        strokeSelectorBackground.backgroundColor = .white
        bottomMenuContainer.addSubview(strokeSelectorBackground)
        
        NSLayoutConstraint.activate([
            strokeSelectorBackground.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: DrawingViewConstants.leftMargin),
            strokeSelectorBackground.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            strokeSelectorBackground.heightAnchor.constraint(equalToConstant: DrawingViewConstants.verticalSelectorHeight),
            strokeSelectorBackground.widthAnchor.constraint(equalToConstant: DrawingViewConstants.verticalSelectorWidth),
        ])
        
        strokeSelectorBackground.alpha = 0
    }
    
    /// Sets up the area of the stroke selector that can be panned
    private func setUpStrokeSelectorPannableArea() {
        strokeSelectorPannableArea.accessibilityIdentifier = "Editor Stroke Selector Pannable Area"
        strokeSelectorPannableArea.translatesAutoresizingMaskIntoConstraints = false
        strokeSelectorBackground.addSubview(strokeSelectorPannableArea)
        
        NSLayoutConstraint.activate([
            strokeSelectorPannableArea.leadingAnchor.constraint(equalTo: strokeSelectorBackground.leadingAnchor),
            strokeSelectorPannableArea.trailingAnchor.constraint(equalTo: strokeSelectorBackground.trailingAnchor),
            strokeSelectorPannableArea.bottomAnchor.constraint(equalTo: strokeSelectorBackground.bottomAnchor, constant: -DrawingViewConstants.strokeSelectorPadding),
            strokeSelectorPannableArea.topAnchor.constraint(equalTo: strokeSelectorBackground.topAnchor, constant: DrawingViewConstants.strokeSelectorPadding + (DrawingViewConstants.strokeCircleMaxSize - DrawingViewConstants.strokeCircleMinSize) / 2),
        ])
    }
    
    /// Sets up the moving circle inside the stroke selector
    private func setUpStrokeSelectorCircle() {
        strokeSelectorCircle.accessibilityIdentifier = "Editor Stroke Selector Circle"
        strokeSelectorCircle.image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        strokeSelectorCircle.tintColor = .black
        strokeSelectorCircle.isUserInteractionEnabled = true
        strokeSelectorCircle.translatesAutoresizingMaskIntoConstraints = false
        strokeSelectorCircle.contentMode = .scaleAspectFill
        strokeSelectorCircle.clipsToBounds = true
        strokeSelectorPannableArea.addSubview(strokeSelectorCircle)
        
        NSLayoutConstraint.activate([
            strokeSelectorCircle.heightAnchor.constraint(equalToConstant: DrawingViewConstants.strokeCircleMinSize),
            strokeSelectorCircle.widthAnchor.constraint(equalToConstant: DrawingViewConstants.strokeCircleMinSize),
            strokeSelectorCircle.centerXAnchor.constraint(equalTo: strokeSelectorPannableArea.centerXAnchor),
            strokeSelectorCircle.bottomAnchor.constraint(equalTo: strokeSelectorPannableArea.bottomAnchor),
        ])
    }
    
    // MARK: Layout: Texture selector
    
    /// Sets up the texture button in the main menu
    private func setUpTextureButton() {
        textureButton.contentMode = .center
        textureButton.image = KanvasCameraImages.pencilImage
        textureButton.accessibilityIdentifier = "Editor Texture Button"
        textureButton.backgroundColor = .white
        bottomMenuContainer.addSubview(textureButton)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = DrawingViewConstants.leftMargin + cellSpace
        NSLayoutConstraint.activate([
            textureButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            textureButton.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            textureButton.heightAnchor.constraint(equalToConstant: CircularImageView.size),
            textureButton.widthAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(textureButtonTapped(recognizer:)))
        textureButton.addGestureRecognizer(tapRecognizer)
    }
    
    /// Sets up the rounded white background for the texture selector
    private func setUpTextureSelectorBackground() {
        textureSelectorBackground.accessibilityIdentifier = "Editor Texture Selector Background"
        textureSelectorBackground.backgroundColor = .white
        bottomMenuContainer.addSubview(textureSelectorBackground)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = DrawingViewConstants.leftMargin + cellSpace
        NSLayoutConstraint.activate([
            textureSelectorBackground.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            textureSelectorBackground.bottomAnchor.constraint(equalTo: bottomMenuContainer.bottomAnchor),
            textureSelectorBackground.heightAnchor.constraint(equalToConstant: DrawingViewConstants.verticalSelectorHeight),
            textureSelectorBackground.widthAnchor.constraint(equalToConstant: DrawingViewConstants.verticalSelectorWidth),
        ])
        
        textureSelectorBackground.alpha = 0
    }
    
    /// Sets up the stack view that holds the texture options
    private func setUpTextureOptionContainer() {
        textureOptionsContainer.translatesAutoresizingMaskIntoConstraints = false
        textureOptionsContainer.axis = .vertical
        textureOptionsContainer.distribution = .equalSpacing
        textureOptionsContainer.alignment = .center
        textureSelectorBackground.addSubview(textureOptionsContainer)
        
        NSLayoutConstraint.activate([
            textureOptionsContainer.leadingAnchor.constraint(equalTo: textureSelectorBackground.leadingAnchor),
            textureOptionsContainer.trailingAnchor.constraint(equalTo: textureSelectorBackground.trailingAnchor),
            textureOptionsContainer.topAnchor.constraint(equalTo: textureSelectorBackground.topAnchor, constant: DrawingViewConstants.textureSelectorPadding),
            textureOptionsContainer.bottomAnchor.constraint(equalTo: textureSelectorBackground.bottomAnchor, constant: -DrawingViewConstants.textureSelectorPadding),
        ])
    }
    
    /// Adds the texture options to the stack view
    private func setUpTextureOptions() {
        sharpieButton.setBackgroundImage(KanvasCameraImages.sharpieImage, for: .normal)
        pencilButton.setBackgroundImage(KanvasCameraImages.pencilImage, for: .normal)
        markerButton.setBackgroundImage(KanvasCameraImages.markerImage, for: .normal)
        
        let sharpieButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(sharpieButtonTapped(recognizer:)))
        let pencilButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(pencilButtonTapped(recognizer:)))
        let markerButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(markerButtonTapped(recognizer:)))
        
        sharpieButton.addGestureRecognizer(sharpieButtonRecognizer)
        pencilButton.addGestureRecognizer(pencilButtonRecognizer)
        markerButton.addGestureRecognizer(markerButtonRecognizer)

        textureOptionsContainer.addArrangedSubview(sharpieButton)
        textureOptionsContainer.addArrangedSubview(pencilButton)
        textureOptionsContainer.addArrangedSubview(markerButton)
    }
    
    // MARK: Layout: Color picker
    
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
        eyeDropperButton.backgroundColor = DrawingViewConstants.colorPickerColors.first
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
    
    /// Sets up the horizontal gradient view in the color picker menu
    private func setUpColorPickerSelector() {
        colorPickerSelectorBackground.accessibilityIdentifier = "Editor Color Picker Selector Background"
        colorPickerSelectorBackground.layer.borderWidth = 0
        colorPickerSelectorBackground.backgroundColor = .clear
        
        colorPickerContainer.addSubview(colorPickerSelectorBackground)
        
        let cellSpace = CircularImageView.size + CircularImageView.padding * 2
        let margin = DrawingViewConstants.leftMargin + cellSpace * 2
        NSLayoutConstraint.activate([
            colorPickerSelectorBackground.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: margin),
            colorPickerSelectorBackground.trailingAnchor.constraint(equalTo: colorPickerContainer.trailingAnchor, constant: -DrawingViewConstants.rightMargin),
            colorPickerSelectorBackground.bottomAnchor.constraint(equalTo: colorPickerContainer.bottomAnchor),
            colorPickerSelectorBackground.heightAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
        
        
        setColorPickerGradient()
        setColorPickerMainColors()
    }
    
    /// Sets up the gradient inside the color picker selector
    private func setColorPickerGradient() {
        colorPickerGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        colorPickerGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        colorPickerGradient.frame = colorPickerSelectorBackground.bounds
        colorPickerSelectorBackground.layer.insertSublayer(colorPickerGradient, at: 0)
    }
    
    /// Sets the main colors in the color picker gradient
    func setColorPickerMainColors() {
        colorPickerGradient.colors = DrawingViewConstants.colorPickerColors.map { $0.cgColor }
        colorPickerGradient.locations = DrawingViewConstants.colorPickerColorLocations
    }
    
    /// Sets the light-to-dark colors in the color picker gradient
    func setColorPickerLightToDarkColors(_ mainColor: UIColor) {
        colorPickerGradient.colors = [UIColor.white.cgColor, mainColor.cgColor, UIColor.black.cgColor]
        colorPickerGradient.locations = [0.0, 0.5, 1.0]
    }
    
    /// Sets up the area of the color picker in which the user can pan
    private func setUpColorPickerSelectorPannableArea() {
        colorPickerSelectorPannableArea.accessibilityIdentifier = "Editor Color Picker Selector Pannable Area"
        colorPickerSelectorPannableArea.translatesAutoresizingMaskIntoConstraints = false
        colorPickerSelectorBackground.addSubview(colorPickerSelectorPannableArea)
        
        NSLayoutConstraint.activate([
            colorPickerSelectorPannableArea.leadingAnchor.constraint(equalTo: colorPickerSelectorBackground.leadingAnchor, constant: DrawingViewConstants.horizontalSelectorPadding),
            colorPickerSelectorPannableArea.trailingAnchor.constraint(equalTo: colorPickerSelectorBackground.trailingAnchor, constant: -DrawingViewConstants.horizontalSelectorPadding),
            colorPickerSelectorPannableArea.bottomAnchor.constraint(equalTo: colorPickerSelectorBackground.bottomAnchor),
            colorPickerSelectorPannableArea.topAnchor.constraint(equalTo: colorPickerSelectorBackground.topAnchor),
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(colorPickerSelectorTapped(recognizer:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(colorPickerSelectorPanned(recognizer:)))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(colorPickerSelectorLongPressed(recognizer:)))
        colorPickerSelectorPannableArea.addGestureRecognizer(tapRecognizer)
        colorPickerSelectorPannableArea.addGestureRecognizer(panRecognizer)
        colorPickerSelectorPannableArea.addGestureRecognizer(longPressRecognizer)
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
    
    @objc func strokeButtonLongPressed(recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPressStrokeButton(recognizer: recognizer)
    }
    
    @objc func textureButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapTextureButton()
    }
    
    @objc func sharpieButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapSharpieButton()
    }
    
    @objc func pencilButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapPencilButton()
    }
    
    @objc func markerButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapMarkerButton()
    }
    
    @objc func colorPickerButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapColorPickerButton()
    }
    
    @objc func closeColorPickerButtonTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapCloseColorPickerButton()
    }
    
    @objc func eyeDropperTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapEyeDropper()
    }
    
    @objc func colorPickerSelectorTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapColorPickerSelector(recognizer: recognizer)
    }
    
    @objc func colorPickerSelectorPanned(recognizer: UIPanGestureRecognizer) {
        delegate?.didPanColorPickerSelector(recognizer: recognizer)
    }
    
    @objc func colorPickerSelectorLongPressed(recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPressColorPickerSelector(recognizer: recognizer)
    }
    
    @objc func colorSelecterPanned(recognizer: UIPanGestureRecognizer) {
        delegate?.didPanColorSelecter(recognizer: recognizer)
    }
    
    // MARK: - Gradients
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateGradients()
    }
    
    private func updateGradients() {
        colorPickerGradient.frame = colorPickerSelectorBackground.bounds
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
    
    /// shows or hides the stroke selector
    ///
    /// - Parameter show: true to show, false to hide
    func showStrokeSelectorBackground(_ show: Bool) {
        UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
            self.strokeSelectorBackground.alpha = show ? 1 : 0
        }
    }
    
    /// changes the image inside the texture button
    ///
    /// - Parameter image: the new image for the icon
    func changeTextureIcon(image: UIImage?) {
        UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
            self.textureButton.image = image
        }
    }
    
    /// shows or hides the texture selector
    ///
    /// - Parameter show: true to show, false to hide
    func showTextureSelectorBackground(_ show: Bool) {
        UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
            self.textureSelectorBackground.alpha = show ? 1 : 0
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
        }
    }
    
    /// shows or hides the overlay of the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showOverlay(_ show: Bool) {
        UIView.animate(withDuration: DrawingViewConstants.animationDuration) {
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
    
    /// enables or disables drawing on the drawing canvas
    ///
    /// - Parameter enable: true to enable, false to disable
    func enableDrawingCanvas(_ enable: Bool) {
        drawingCanvas.isUserInteractionEnabled = enable
    }
    
    // MARK: - DrawingCanvasDelegate
    
    func onCanvasTouchesBegan() {
        onDrawing(active: true)
    }
    
    func onCanvasTouchesEnded() {
        onDrawing(active: false)
    }
    
    /// shows/hides the menus when drawing
    ///
    /// - Parameter active: whether the user is currently drawing or not
    private func onDrawing(active: Bool) {
        showTopButtons(!active)
        showBottomPanel(!active)
    }
}


protocol DrawingCanvasDelegate: class {
    func onCanvasTouchesBegan()
    func onCanvasTouchesEnded()
}

/// View that shows/hides the menus when touched
final class DrawingCanvas: UIView {
    
    weak var delegate: DrawingCanvasDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.onCanvasTouchesBegan()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.onCanvasTouchesEnded()
    }
}
