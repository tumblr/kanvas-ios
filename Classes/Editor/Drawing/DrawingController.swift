//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol DrawingControllerDelegate: class {
    /// Called to ask if color selecter tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func editorShouldShowColorSelecterTooltip() -> Bool
    
    /// Called after the color selecter tooltip is dismissed
    func didDismissColorSelecterTooltip()
    
    /// Called after the stroke animation has ended
    func didEndStrokeSelectorAnimation()
    
    /// Called to ask if stroke selector animation should be shown
    ///
    /// - Returns: Bool for animation
    func editorShouldShowStrokeSelectorAnimation() -> Bool
    
    /// Called after the close button was tapped
    func didTapCloseButton()
    
    /// Called when the color selecter is panned
    ///
    /// - Parameter point: location to take the color from
    /// - Returns: Color from image
    func getColor(from point: CGPoint) -> UIColor
}

/// Constants for Drawing Controller
private struct DrawingControllerConstants {
    static let animationDuration: TimeInterval = 0.25
}

private enum DrawingMode {
    case draw
    case erase
}

/// Controller for handling the drawing menu.
final class DrawingController: UIViewController, DrawingViewDelegate, ColorCollectionControllerDelegate {
    
    weak var delegate: DrawingControllerDelegate?
    
    private lazy var drawingView: DrawingView = {
        let view = DrawingView()
        view.delegate = self
        return view
    }()
    
    private lazy var colorCollectionController: ColorCollectionController = {
        let controller = ColorCollectionController()
        controller.delegate = self
        return controller
    }()
    
    // Drawing
    var drawingLayer: CALayer?
    private var drawingColor: UIColor
    private var mode: DrawingMode
    
    // Color picker and selecter
    private var colorSelecterOrigin: CGPoint
    
    
    // MARK: Initializers
    
    init() {
        drawingColor = .tumblrBrightBlue
        colorSelecterOrigin = CGPoint.zero
        mode = .draw
        
        super.init(nibName: .none, bundle: .none)
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    
    // MARK: - View Life Cycle
    
    override func loadView() {
        view = drawingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpRecognizers()
        
        load(childViewController: colorCollectionController, into: drawingView.colorCollection)
    }
    
    // MARK: - View
    
    private func setUpView() {
        drawingView.alpha = 0
    }
    
    // MARK: - Gesture Recognizers
    
    private func setUpRecognizers() {
        setUpTopOptions()
        setUpStrokeButton()
        setUpTextureButton()
        setUpTextureOptions()
        setUpColorPickerButton()
        setUpCloseColorPickerButton()
        setUpEyeDropper()
        setUpColorPickerSelectorPannableArea()
        setUpColorSelecter()
    }
    
    /// Sets up the gesture recognizers for the top options
    private func setUpTopOptions() {
        let confirmButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(confirmButtonTapped(recognizer:)))
        let undoButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(undoButtonTapped(recognizer:)))
        let eraseButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(eraseButtonTapped(recognizer:)))
        
        drawingView.confirmButton.addGestureRecognizer(confirmButtonRecognizer)
        drawingView.undoButton.addGestureRecognizer(undoButtonRecognizer)
        drawingView.eraseButton.addGestureRecognizer(eraseButtonRecognizer)
    }
    
    /// Sets up the gesture recognizers for the texture options
    private func setUpTextureOptions() {
        let sharpieButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(sharpieButtonTapped(recognizer:)))
        let pencilButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(pencilButtonTapped(recognizer:)))
        let markerButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(markerButtonTapped(recognizer:)))
        
        drawingView.sharpieButton.addGestureRecognizer(sharpieButtonRecognizer)
        drawingView.pencilButton.addGestureRecognizer(pencilButtonRecognizer)
        drawingView.markerButton.addGestureRecognizer(markerButtonRecognizer)
    }
    
    private func setUpStrokeButton() {
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: #selector(strokeButtonLongPressed(recognizer:)))
        longPressRecognizer.minimumPressDuration = 0
        drawingView.strokeButton.addGestureRecognizer(longPressRecognizer)
    }
    
    private func setUpTextureButton() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(textureButtonTapped(recognizer:)))
        drawingView.textureButton.addGestureRecognizer(tapRecognizer)
    }
    
    private func setUpColorPickerButton() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(colorPickerTapped(recognizer:)))
        drawingView.colorPickerButton.addGestureRecognizer(tapRecognizer)
    }
    
    private func setUpCloseColorPickerButton() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(closeColorPickerButtonTapped(recognizer:)))
        drawingView.closeColorPickerButton.addGestureRecognizer(tapRecognizer)
    }
    
    private func setUpEyeDropper() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(eyeDropperTapped(recognizer:)))
        drawingView.eyeDropperButton.addGestureRecognizer(tapRecognizer)
    }
    
    private func setUpColorPickerSelectorPannableArea() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(colorPickerSelectorTapped(recognizer:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(colorPickerSelectorPanned(recognizer:)))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(colorPickerSelectorLongPressed(recognizer:)))
        drawingView.colorPickerSelectorPannableArea.addGestureRecognizer(tapRecognizer)
        drawingView.colorPickerSelectorPannableArea.addGestureRecognizer(panRecognizer)
        drawingView.colorPickerSelectorPannableArea.addGestureRecognizer(longPressRecognizer)
    }
    
    private func setUpColorSelecter() {
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(colorSelecterPanned(recognizer:)))
        drawingView.colorSelecter.addGestureRecognizer(panRecognizer)
    }
    
    private func setDrawingColor(_ color: UIColor, addToColorCollection: Bool = false) {
        drawingColor = color
        mode = .draw
        changeEraseIcon(selected: false)
        
        if addToColorCollection {
            colorCollectionController.addColor(color)
        }
    }
    
    
    // MARK: - View animations
    
    /// toggles the erase icon
    ///
    /// - Parameter selected: true to selected icon, false to unselected icon
    private func changeEraseIcon(selected: Bool) {
        drawingView.changeEraseIcon(selected: selected)
    }
    
    /// shows or hides the bottom panel (it includes the buttons menu and the color picker)
    ///
    /// - Parameter show: true to show, false to hide
    func showBottomPanel(_ show: Bool) {
        drawingView.showBottomPanel(show)
    }
    
    /// shows or hides the stroke selector
    ///
    /// - Parameter show: true to show, false to hide
    private func showStrokeSelectorBackground(_ show: Bool) {
        drawingView.showStrokeSelectorBackground(show)
    }
    
    /// changes the image inside the texture button
    ///
    /// - Parameter image: the new image for the icon
    private func changeTextureIcon(image: UIImage?) {
        drawingView.changeTextureIcon(image: image)
    }
    
    /// shows or hides the texture selector
    ///
    /// - Parameter show: true to show, false to hide
    private func showTextureSelectorBackground(_ show: Bool) {
        drawingView.showTextureSelectorBackground(show)
    }
    
    /// shows or hides the color picker and its buttons
    ///
    /// - Parameter show: true to show, false to hide
    private func showColorPickerContainer(_ show: Bool) {
        drawingView.showColorPickerContainer(show)
    }
    
    /// shows or hides the stroke, texture, gradient, and recently-used color buttons
    ///
    /// - Parameter show: true to show, false to hide
    private func showBottomMenu(_ show: Bool) {
        drawingView.showBottomMenu(show)
    }
    
    /// shows or hides the erase and undo buttons
    ///
    /// - Parameter show: true to show, false to hide
    private func showTopButtons(_ show: Bool) {
        drawingView.showTopButtons(show)
    }
    
    /// shows or hides the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    private func showColorSelecter(_ show: Bool) {
        drawingView.showColorSelecter(show)
    }
    
    /// shows or hides the overlay of the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    private func showOverlay(_ show: Bool) {
        drawingView.showOverlay(show)
    }
    
    /// shows or hides the tooltip above color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showTooltip(_ show: Bool) {
        drawingView.showTooltip(show)
    }
    
    /// enables or disables the user interaction on the drawing canvas
    ///
    /// - Parameter enable: true to enable, false to disable
    private func enableDrawingCanvas(_ enable: Bool) {
        drawingView.enableDrawingCanvas(enable)
    }
    
    /// Shows the stroke selector animation for onboarding
    private func showStrokeSelectorAnimation() {
        let duration = 4.0
        let maxScale = DrawingView.strokeCircleMaxSize / DrawingView.strokeCircleMinSize
        let maxHeight = (drawingView.strokeSelectorPannableArea.bounds.height + drawingView.strokeSelectorCircle.bounds.height) / 2
        
        drawingView.isUserInteractionEnabled = false
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5 / duration, animations: {
                self.drawingView.overlay.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5 / duration, relativeDuration: 0.5 / duration, animations: {
                self.drawingView.strokeSelectorBackground.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 1.0 / duration, relativeDuration: 1.0 / duration, animations: {
                var transform = CGAffineTransform(translationX: 0.0, y: -maxHeight)
                transform = transform.concatenating(CGAffineTransform(scaleX: maxScale, y: maxScale))
                self.drawingView.strokeSelectorCircle.transform = transform
            })
            UIView.addKeyframe(withRelativeStartTime: 2.0 / duration, relativeDuration: 1.0 / duration, animations: {
                var transform = CGAffineTransform(translationX: 0.0, y: 0.0)
                transform = transform.concatenating(CGAffineTransform(scaleX: 1.0, y: 1.0))
                self.drawingView.strokeSelectorCircle.transform = transform
            })
            UIView.addKeyframe(withRelativeStartTime: 3.0 / duration, relativeDuration: 0.5 / duration, animations: {
                self.drawingView.strokeSelectorBackground.alpha = 0
            })
            UIView.addKeyframe(withRelativeStartTime: 3.5 / duration, relativeDuration: 0.5 / duration, animations: {
                self.drawingView.overlay.alpha = 0
            })
        }, completion: { _ in
            self.drawingView.isUserInteractionEnabled = true
        })
    }
    
    // MARK: - Gesture Recognizer Selectors
    
    @objc private func confirmButtonTapped(recognizer: UITapGestureRecognizer) {
        showTextureSelectorBackground(false)
        delegate?.didTapCloseButton()
    }
    
    @objc private func undoButtonTapped(recognizer: UITapGestureRecognizer) {
        
    }
    
    @objc private func eraseButtonTapped(recognizer: UITapGestureRecognizer) {
        if mode == .draw {
            mode = .erase
            changeEraseIcon(selected: true)
        }
        else {
            mode = .draw
            changeEraseIcon(selected: false)
        }
    }
    
    @objc private func strokeButtonLongPressed(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            showStrokeSelectorBackground(true)
        case .changed:
            strokeSelectorPanned(recognizer: recognizer)
        case .ended:
            showStrokeSelectorBackground(false)
        default:
            break
        }
    }
    
    private func strokeSelectorPanned(recognizer: UILongPressGestureRecognizer) {
        let point = getStrokeCirclePosition(with: recognizer, in: drawingView.strokeSelectorPannableArea)
        if drawingView.strokeSelectorPannableArea.bounds.contains(point) {
            setStrokeCircleLocation(location: point)
            setStrokeCircleSize(percent: 100.0 - point.y)
        }
    }
    
    private func getStrokeCirclePosition(with recognizer: UILongPressGestureRecognizer, in view: UIView) -> CGPoint {
        let x = DrawingView.verticalSelectorWidth / 2
        let y = recognizer.location(in: view).y
        return CGPoint(x: x, y: y)
    }
    
    private func setStrokeCircleLocation(location: CGPoint) {
        drawingView.strokeSelectorCircle.center = location
    }
    
    private func setStrokeCircleSize(percent: CGFloat) {
        let maxIncrement = (DrawingView.strokeCircleMaxSize / DrawingView.strokeCircleMinSize) - 1
        let scale = 1.0 + maxIncrement * percent / 100.0
        drawingView.strokeSelectorCircle.transform = CGAffineTransform(scaleX: scale, y: scale)
        drawingView.strokeButtonCircle.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    @objc private func textureButtonTapped(recognizer: UITapGestureRecognizer) {
        showTextureSelectorBackground(true)
    }
    
    @objc private func pencilButtonTapped(recognizer: UITapGestureRecognizer) {
        changeTextureIcon(image: KanvasCameraImages.pencilImage)
        showTextureSelectorBackground(false)
    }
    
    @objc private func markerButtonTapped(recognizer: UITapGestureRecognizer) {
        changeTextureIcon(image: KanvasCameraImages.markerImage)
        showTextureSelectorBackground(false)
    }
    
    @objc private func sharpieButtonTapped(recognizer: UITapGestureRecognizer) {
        changeTextureIcon(image: KanvasCameraImages.sharpieImage)
        showTextureSelectorBackground(false)
    }
    
    @objc private func colorPickerTapped(recognizer: UITapGestureRecognizer) {
        showBottomMenu(false)
        showTextureSelectorBackground(false)
        showColorPickerContainer(true)
    }
    
    @objc private func closeColorPickerButtonTapped(recognizer: UITapGestureRecognizer) {
        showColorPickerContainer(false)
        showBottomMenu(true)
    }
    
    @objc private func eyeDropperTapped(recognizer: UITapGestureRecognizer) {
        resetColorSelecterLocation()
        showColorPickerContainer(false)
        showTopButtons(false)
        resetColorSelecterColor()
        showColorSelecter(true)
        enableDrawingCanvas(false)
        
        if delegate?.editorShouldShowColorSelecterTooltip() == true {
            showOverlay(true)
            showTooltip(true)
        }
    }
    
    @objc private func colorPickerSelectorTapped(recognizer: UITapGestureRecognizer) {
        selectColor(recognizer: recognizer, addToColorCollection: true)
    }
    
    @objc private func colorPickerSelectorPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            selectColor(recognizer: recognizer)
        case .ended:
            selectColor(recognizer: recognizer, addToColorCollection: true)
        default:
            break
        }
    }
    
    @objc private func colorPickerSelectorLongPressed(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            selectColor(recognizer: recognizer)
            setColorPickerLightToDarkColors()
        case .changed:
            selectColor(recognizer: recognizer)
        case .ended, .cancelled, .failed:
            selectColor(recognizer: recognizer, addToColorCollection: true)
            setColorPickerMainColors()
        default:
            break
        }
    }
    
    @objc private func colorSelecterPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if delegate?.editorShouldShowColorSelecterTooltip() == true {
                showTooltip(false)
                showOverlay(false)
            }
        case .changed:
            let currentLocation = moveColorSelecter(recognizer: recognizer)
            let color = getColor(at: currentLocation)
            setColorSelecterColor(color)
        case .ended, .failed, .cancelled:
            let currentLocation = moveColorSelecter(recognizer: recognizer)
            let color = getColor(at: currentLocation)
            setEyeDropperColor(color)
            setDrawingColor(color, addToColorCollection: true)
            
            showColorSelecter(false)
            showColorPickerContainer(true)
            showTopButtons(true)
            enableDrawingCanvas(true)
        default:
            break
        }
    }
    
    // MARK: - Color Picker
    
    private func setColorPickerMainColors() {
        drawingView.setColorPickerMainColors()
    }
    
    func setColorPickerLightToDarkColors() {
        drawingView.setColorPickerLightToDarkColors(drawingColor)
    }
    
    private func selectColor(recognizer: UIGestureRecognizer, addToColorCollection: Bool = false) {
        guard let selectorView = recognizer.view else { return }
        let point = getColorPosition(with: recognizer, in: selectorView)
        let color = getColor(at: point.x + DrawingView.horizontalSelectorPadding)
        setEyeDropperColor(color)
        setDrawingColor(color, addToColorCollection: addToColorCollection)
    }
    
    private func getColorPosition(with recognizer: UIGestureRecognizer, in view: UIView) -> CGPoint {
        let x = recognizer.location(in: view).x
        let y = drawingView.colorPickerSelectorBackground.frame.height / 2
        var point = CGPoint(x: x, y: y)
        
        if !view.bounds.contains(point) {
            if point.x < 0  {
                point.x = 0
            }
            else {
                point.x = view.bounds.width
            }
        }
        
        return point
    }
    
    private func setEyeDropperColor(_ color: UIColor) {
        drawingView.eyeDropperButton.backgroundColor = color
    }
    
    private func setColorSelecterColor(_ color: UIColor) {
        drawingView.colorSelecter.backgroundColor = color.withAlphaComponent(DrawingView.colorSelecterAlpha)
    }
    
    private func getColor(at x: CGFloat, defaultColor: UIColor = .white) -> UIColor {
        let colorPickerPercent = x / drawingView.colorPickerSelectorBackground.frame.width
        
        guard let locations: [NSNumber] = drawingView.colorPickerGradient.locations,
            let colors = drawingView.colorPickerGradient.colors as? [CGColor],
            let upperBound = locations.firstIndex(where: { CGFloat($0.floatValue) > colorPickerPercent }) else { return defaultColor }
        
        let lowerBound = upperBound - 1
        
        let firstColor = UIColor(cgColor: colors[lowerBound])
        let secondColor = UIColor(cgColor: colors[upperBound])
        let distanceBetweenColors = locations[upperBound].floatValue - locations[lowerBound].floatValue
        let percentBetweenColors = (colorPickerPercent.f - locations[lowerBound].floatValue) / distanceBetweenColors
        return UIColor.lerp(from: RGBA(color: firstColor), to: RGBA(color: secondColor), percent: CGFloat(percentBetweenColors))
    }
    
    private func resetColorSelecterLocation() {
        let initialPoint = drawingView.colorPickerContainer.convert(drawingView.eyeDropperButton.center, to: drawingView)
        drawingView.colorSelecter.center = initialPoint
        drawingView.colorSelecter.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        colorSelecterOrigin = initialPoint
    }
    
    private func resetColorSelecterColor() {
        let color = getColor(at: colorSelecterOrigin)
        setColorSelecterColor(color)
        setDrawingColor(color)
    }
    
    private func moveColorSelecter(recognizer: UIPanGestureRecognizer) -> CGPoint {
        let translation = recognizer.translation(in: drawingView.colorSelecter.superview)
        let point = CGPoint(x: colorSelecterOrigin.x + translation.x, y: colorSelecterOrigin.y + translation.y)
        drawingView.colorSelecter.center = point
        return point
    }
    
    private func getColor(at point: CGPoint) -> UIColor {
        guard let delegate = delegate else { return .black }
        return delegate.getColor(from: point)
    }
    
    // MARK: - DrawingViewDelegate
    
    func didDismissColorSelecterTooltip() {
        delegate?.didDismissColorSelecterTooltip()
    }
    
    // MARK: - ColorCollectionControllerDelegate
    
    func didSelectColor(_ color: UIColor) {
        setDrawingColor(color)
    }
    
    // MARK: - Public interface
    
    
    /// Adds colors to the color carousel
    ///
    /// - Parameter colors: list of colors to be added
    func addColorsForCarousel(colors: [UIColor]) {
        colorCollectionController.addColors(colors)
    }
    
    /// shows or hides the drawing menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: DrawingControllerConstants.animationDuration, animations: {
            self.drawingView.alpha = show ? 1 : 0
        }, completion: { _ in
            if show && self.delegate?.editorShouldShowStrokeSelectorAnimation() == true {
                self.showStrokeSelectorAnimation()
                self.delegate?.didEndStrokeSelectorAnimation()
            }
        })
    }

}
