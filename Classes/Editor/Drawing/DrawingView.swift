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
}

private struct DrawingViewConstants {
    static let animationDuration: TimeInterval = 0.25
    
    // Icon margins
    static let topMargin: CGFloat = 19.5
    static let bottomMargin: CGFloat = 25
    static let leftMargin: CGFloat = 20
    static let rightMargin: CGFloat = 20
    
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
    
    // Drawing
    let drawingCanvas: DrawingCanvas
    let temporalImageView: UIImageView
    
    // Main containers
    let topButtonContainer: UIStackView
    let bottomPanelContainer: UIView
    
    // Bottom panel containers
    let bottomMenuContainer: UIView
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
    let textureOptionsStackView: UIStackView
    
    // Color picker
    let colorPickerButton: CircularImageView
    let colorPickerSelectorBackground: CircularImageView
    let colorPickerSelectorPannableArea: UIView
    let colorPickerGradient: CAGradientLayer
    let closeColorPickerButton: CircularImageView
    
    // Eye Dropper
    let eyeDropperButton: CircularImageView
    
    // Color selecter
    let colorSelecter: CircularImageView
    let overlay: UIView
    var tooltip: EasyTipView?
    
    // Color collection
    let colorCollection: UIView
    
    init() {
        drawingCanvas = DrawingCanvas()
        temporalImageView = UIImageView()
        topButtonContainer = UIStackView()
        bottomPanelContainer = IgnoreTouchesView()
        bottomMenuContainer = IgnoreTouchesView()
        colorPickerContainer = IgnoreTouchesView()
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
        textureOptionsStackView = UIStackView()
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
        setUpTopButtons()
        setUpOverlay()
        setUpBottomPanel()
        setUpBottomMenu()
        setUpColorPicker()
    }
    
    private func setUpBottomMenu() {
        setUpBottomMenuContainer()
        
        setUpStrokeButton()
        setUpStrokeButtonCircle()
        setUpStrokeSelectorBackground()
        setUpStrokeSelectorPannableArea()
        setUpStrokeSelectorCircle()
        
        setUpTextureButton()
        setUpTextureSelectorBackground()
        setUpTextureOptions()
        
        setUpColorCollection()
    }
    
    private func setUpColorPicker() {
        setUpColorPickerContainer()
        setUpColorPickerButton()
        setUpCloseColorPickerButton()
        setUpEyeDropper()
        setUpColorPickerSelector()
        setUpColorPickerSelectorPannableArea()
        
        setUpColorSelecter()
        setUpTooltip()
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
    
    private func setUpTopButtons() {
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
    
    private func setUpBottomMenuContainer() {
        bottomMenuContainer.accessibilityIdentifier = "Editor Bottom Menu Container"
        bottomMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomMenuContainer.clipsToBounds = true
        
        bottomMenuContainer.add(into: bottomPanelContainer)
    }
    
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
    }
    
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
    }
    
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
    
    private func setUpTextureOptions() {
        textureOptionsStackView.translatesAutoresizingMaskIntoConstraints = false
        textureOptionsStackView.axis = .vertical
        textureOptionsStackView.distribution = .equalSpacing
        textureOptionsStackView.alignment = .center
        textureSelectorBackground.addSubview(textureOptionsStackView)
        
        NSLayoutConstraint.activate([
            textureOptionsStackView.leadingAnchor.constraint(equalTo: textureSelectorBackground.leadingAnchor),
            textureOptionsStackView.trailingAnchor.constraint(equalTo: textureSelectorBackground.trailingAnchor),
            textureOptionsStackView.topAnchor.constraint(equalTo: textureSelectorBackground.topAnchor, constant: DrawingViewConstants.textureSelectorPadding),
            textureOptionsStackView.bottomAnchor.constraint(equalTo: textureSelectorBackground.bottomAnchor, constant: -DrawingViewConstants.textureSelectorPadding),
        ])
    }
    
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
    }
    
    private func setUpColorPickerContainer() {
        colorPickerContainer.accessibilityIdentifier = "Editor Color Picker Container"
        colorPickerContainer.translatesAutoresizingMaskIntoConstraints = false
        colorPickerContainer.clipsToBounds = true
        
        colorPickerContainer.add(into: bottomPanelContainer)
        
        colorPickerContainer.alpha = 0
    }
    
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
    }
    
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
    }
    
    
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
    
    private func setColorPickerGradient() {
        colorPickerGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        colorPickerGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        colorPickerGradient.frame = colorPickerSelectorBackground.bounds
        colorPickerSelectorBackground.layer.insertSublayer(colorPickerGradient, at: 0)
    }
    
    func setColorPickerMainColors() {
        colorPickerGradient.colors = DrawingViewConstants.colorPickerColors.map { $0.cgColor }
        colorPickerGradient.locations = DrawingViewConstants.colorPickerColorLocations
    }
    
    func setColorPickerLightToDarkColors(_ mainColor: UIColor) {
        colorPickerGradient.colors = [UIColor.white.cgColor, mainColor.cgColor, UIColor.black.cgColor]
        colorPickerGradient.locations = [0.0, 0.5, 1.0]
    }
    
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
    }
    
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
    }
    
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
        guard let eraseButton = topButtonContainer.arrangedSubviews.object(at: 2) as? UIImageView else { return }
        
        UIView.transition(with: eraseButton, duration: DrawingViewConstants.animationDuration, options: .transitionCrossDissolve, animations: {
            eraseButton.image = image
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
                self.tooltip?.alpha = 0
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
        showTopButtons(false)
        showBottomPanel(false)
    }
    
    func onCanvasTouchesEnded() {
        showTopButtons(true)
        showBottomPanel(true)
    }
}


protocol DrawingCanvasDelegate: class {
    func onCanvasTouchesBegan()
    func onCanvasTouchesEnded()
}

final class DrawingCanvas: UIView {
    
    weak var delegate: DrawingCanvasDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.onCanvasTouchesBegan()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.onCanvasTouchesEnded()
    }
}
