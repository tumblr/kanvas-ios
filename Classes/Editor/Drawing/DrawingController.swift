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
final class DrawingController: UIViewController, DrawingViewDelegate {
    
    weak var delegate: DrawingControllerDelegate?
    
    private lazy var drawingView: DrawingView = {
        let view = DrawingView()
        view.delegate = self
        return view
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
        colorSelecterOrigin = .zero
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
    }
    
    // MARK: - View
    
    private func setUpView() {
        drawingView.alpha = 0
    }
    
    /// Sets a new color for drawing
    ///
    /// - Parameter color: the new color for drawing
    private func setDrawingColor(_ color: UIColor) {
        drawingColor = color
        mode = .draw
        changeEraseIcon(selected: false)
    }
    
    
    // MARK: - View animations
    
    /// Toggles the erase icon
    ///
    /// - Parameter selected: true to selected icon, false to unselected icon
    private func changeEraseIcon(selected: Bool) {
        drawingView.changeEraseIcon(selected: selected)
    }
    
    /// Shows or hides the bottom panel (it includes the buttons menu and the color picker)
    ///
    /// - Parameter show: true to show, false to hide
    private func showBottomPanel(_ show: Bool) {
        drawingView.showBottomPanel(show)
    }
    
    /// Shows or hides the stroke selector
    ///
    /// - Parameter show: true to show, false to hide
    private func showStrokeSelectorBackground(_ show: Bool) {
        drawingView.showStrokeSelectorBackground(show)
    }
    
    /// Changes the image inside the texture button
    ///
    /// - Parameter image: the new image for the icon
    private func changeTextureIcon(image: UIImage?) {
        drawingView.changeTextureIcon(image: image)
    }
    
    /// Shows or hides the texture selector
    ///
    /// - Parameter show: true to show, false to hide
    private func showTextureSelectorBackground(_ show: Bool) {
        drawingView.showTextureSelectorBackground(show)
    }
    
    /// Shows or hides the color picker and its buttons
    ///
    /// - Parameter show: true to show, false to hide
    private func showColorPickerContainer(_ show: Bool) {
        drawingView.showColorPickerContainer(show)
    }
    
    /// Shows or hides the stroke, texture, gradient, and recently-used color buttons
    ///
    /// - Parameter show: true to show, false to hide
    private func showBottomMenu(_ show: Bool) {
        drawingView.showBottomMenu(show)
    }
    
    /// Shows or hides the erase and undo buttons
    ///
    /// - Parameter show: true to show, false to hide
    private func showTopButtons(_ show: Bool) {
        drawingView.showTopButtons(show)
    }
    
    /// Shows or hides the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    private func showColorSelecter(_ show: Bool) {
        drawingView.showColorSelecter(show)
    }
    
    /// Shows or hides the overlay of the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    private func showOverlay(_ show: Bool) {
        drawingView.showOverlay(show)
    }
    
    /// Shows or hides the tooltip above color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showTooltip(_ show: Bool) {
        drawingView.showTooltip(show)
    }
    
    /// Enables or disables the user interaction on the drawing canvas
    ///
    /// - Parameter enable: true to enable, false to disable
    private func enableDrawingCanvas(_ enable: Bool) {
        drawingView.enableDrawingCanvas(enable)
    }
    
    // MARK: - DrawingViewDelegate
    
    func didDismissColorSelecterTooltip() {
        delegate?.didDismissColorSelecterTooltip()
    }
    
    func didTapConfirmButton() {
        showTextureSelectorBackground(false)
        delegate?.didTapCloseButton()
    }
    
    func didTapUndoButton() {
        
    }
    
    func didTapEraseButton() {
        if mode == .draw {
            mode = .erase
            changeEraseIcon(selected: true)
        }
        else {
            mode = .draw
            changeEraseIcon(selected: false)
        }
    }
    
    func didLongPressStrokeButton(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            showStrokeSelectorBackground(true)
        case .changed:
            strokeSelectorPanned(recognizer: recognizer)
        case .ended, .cancelled, .failed:
            showStrokeSelectorBackground(false)
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    func didTapTextureButton() {
        showTextureSelectorBackground(true)
    }
    
    func didTapPencilButton() {
        changeTextureIcon(image: KanvasCameraImages.pencilImage)
        showTextureSelectorBackground(false)
    }
    
    func didTapSharpieButton() {
        changeTextureIcon(image: KanvasCameraImages.sharpieImage)
        showTextureSelectorBackground(false)
    }
    
    func didTapMarkerButton() {
        changeTextureIcon(image: KanvasCameraImages.markerImage)
        showTextureSelectorBackground(false)
    }
    
    func didTapColorPickerButton() {
        showBottomMenu(false)
        showTextureSelectorBackground(false)
        showColorPickerContainer(true)
    }
    
    func didTapCloseColorPickerButton() {
        showColorPickerContainer(false)
        showBottomMenu(true)
    }
    
    func didTapEyeDropper() {
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
    
    func didTapColorPickerSelector(recognizer: UITapGestureRecognizer) {
        selectColor(recognizer: recognizer)
    }
    
    func didPanColorPickerSelector(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            selectColor(recognizer: recognizer)
        case .possible, .began, .cancelled, .failed:
            break
        @unknown default:
            break
        }
    }
    
    func didLongPressColorPickerSelector(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            selectColor(recognizer: recognizer)
            setColorPickerLightToDarkColors()
        case .changed:
            selectColor(recognizer: recognizer)
        case .ended, .cancelled, .failed:
            selectColor(recognizer: recognizer)
            setColorPickerMainColors()
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    func didPanColorSelecter(recognizer: UIPanGestureRecognizer) {
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
            setDrawingColor(color)
            
            showColorSelecter(false)
            showColorPickerContainer(true)
            showTopButtons(true)
            enableDrawingCanvas(true)
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Private utilities
    
    /// Gets the position of the user's finger on screen,
    /// but adjusts it to fit the horizontal center of the selector.
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Parameter view: the view that contains the circle
    /// - Returns: location of the user's finger
    private func getSelectedLocation(with recognizer: UILongPressGestureRecognizer, in view: UIView) -> CGPoint {
        let x = DrawingView.verticalSelectorWidth / 2
        let y = recognizer.location(in: view).y
        return CGPoint(x: x, y: y)
    }
    
    /// Changes the stroke circle location inside the stroke selector
    ///
    /// - Parameter location: the new position of the circle
    private func moveStrokeSelectorCircle(to location: CGPoint) {
        drawingView.moveStrokeSelectorCircle(to: location)
    }
    
    /// Changes the stroke circle size according to a percent that goes from
    /// the minimum size (0) to the maximum size (100)
    ///
    /// - Parameter percent: the new size of the circle
    private func setStrokeCircleSize(percent: CGFloat) {
        let maxIncrement = (DrawingView.strokeCircleMaxSize / DrawingView.strokeCircleMinSize) - 1
        let scale = 1.0 + maxIncrement * percent / 100.0
        drawingView.transformStrokeCircles(CGAffineTransform(scaleX: scale, y: scale))
    }
    
    private func strokeSelectorPanned(recognizer: UILongPressGestureRecognizer) {
        let point = getSelectedLocation(with: recognizer, in: drawingView.strokeSelectorPannableArea)
        if drawingView.strokeSelectorPannableArea.bounds.contains(point) {
            moveStrokeSelectorCircle(to: point)
            setStrokeCircleSize(percent: 100.0 - point.y)
        }
    }
    
    // MARK: - Color Picker
    
    private func setColorPickerMainColors() {
        drawingView.setColorPickerMainColors()
    }
    
    func setColorPickerLightToDarkColors() {
        drawingView.setColorPickerLightToDarkColors(drawingColor)
    }
    
    private func selectColor(recognizer: UIGestureRecognizer) {
        guard let selectorView = recognizer.view else { return }
        let point = getSelectedGradientLocation(with: recognizer, in: selectorView)
        let color = getColor(at: point.x + DrawingView.horizontalSelectorPadding)
        setEyeDropperColor(color)
        setDrawingColor(color)
    }
    
    /// Gets the position of the color picker gradient that the user is touching.
    /// If the user goes beyond the limits of the view, the location is set to the limit of it.
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Parameter view: the color picker gradient
    /// - Returns: point inside the color picker
    private func getSelectedGradientLocation(with recognizer: UIGestureRecognizer, in view: UIView) -> CGPoint {
        let dimensions = drawingView.getColorPickerDimensions()
        let y = dimensions.height / 2
        let x = recognizer.location(in: view).x
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
    
    /// Sets a new color for the eye dropper button background
    ///
    /// - Parameter color: new color for the eye dropper button
    private func setEyeDropperColor(_ color: UIColor) {
        drawingView.setEyeDropperColor(color)
    }
    
    /// Sets a new color for the color selecter background
    ///
    /// - Parameter color: new color for the color selecter
    private func setColorSelecterColor(_ color: UIColor) {
        drawingView.setColorSelecterColor(color)
    }
    
    /// Gets the color that has been selected from the color picker gradient
    ///
    /// - Parameter x: the horizontal position inside the gradient
    /// - Parameter defaultColor: a color to return in case of an error
    /// - Returns: the selected color
    private func getColor(at x: CGFloat, defaultColor: UIColor = .white) -> UIColor {
        let colorPickerPercent = x / drawingView.getColorPickerDimensions().width
        
        let locations = drawingView.getColorPickerGradientLocations()
        let colors = drawingView.getColorPickerGradientColors()
        
        guard let upperBound = locations.firstIndex(where: { CGFloat($0.floatValue) > colorPickerPercent }) else {
            return defaultColor
        }
        
        let lowerBound = upperBound - 1
        
        let firstColor = UIColor(cgColor: colors[lowerBound])
        let secondColor = UIColor(cgColor: colors[upperBound])
        let distanceBetweenColors = locations[upperBound].floatValue - locations[lowerBound].floatValue
        let percentBetweenColors = (colorPickerPercent.f - locations[lowerBound].floatValue) / distanceBetweenColors
        return UIColor.lerp(from: RGBA(color: firstColor), to: RGBA(color: secondColor), percent: CGFloat(percentBetweenColors))
    }
    
    /// Takes the color selecter back to its initial position (same position as the eye dropper's)
    private func resetColorSelecterLocation() {
        let initialPoint = drawingView.getColorSelecterInitialLocation()
        drawingView.moveColorSelecter(to: initialPoint)
        drawingView.transformColorSelecter(CGAffineTransform(scaleX: 0, y: 0))
        
        colorSelecterOrigin = initialPoint
    }
    
    /// Changes the background color of the color selecter to the one from its initial position
    private func resetColorSelecterColor() {
        let color = getColor(at: colorSelecterOrigin)
        setColorSelecterColor(color)
        setDrawingColor(color)
    }
    
    /// Changes the location of the color selecter to the location of the user's finger
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Returns: the new location of the color selecter
    private func moveColorSelecter(recognizer: UIPanGestureRecognizer) -> CGPoint {
        let translation = recognizer.translation(in: drawingView)
        let point = CGPoint(x: colorSelecterOrigin.x + translation.x, y: colorSelecterOrigin.y + translation.y)
        drawingView.moveColorSelecter(to: point)
        return point
    }
    
    /// Gets the color of a certain point of the media playing on the background
    ///
    /// - Parameter point: the location to take the color from
    /// - Returns: the color of the pixel
    private func getColor(at point: CGPoint) -> UIColor {
        guard let delegate = delegate else { return .black }
        return delegate.getColor(from: point)
    }
    
    
    // MARK: - Public interface
    
    /// shows or hides the drawing menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: DrawingControllerConstants.animationDuration, animations: {
            self.drawingView.alpha = show ? 1 : 0
        }, completion: { _ in
            if show && self.delegate?.editorShouldShowStrokeSelectorAnimation() == true {
                self.drawingView.showStrokeSelectorAnimation()
                self.delegate?.didEndStrokeSelectorAnimation()
            }
        })
    }

}
