//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol DrawingControllerDelegate: AnyObject {
    /// Called to ask if color selector tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func editorShouldShowColorSelectorTooltip() -> Bool
    
    /// Called after the color selector tooltip is dismissed
    func didDismissColorSelectorTooltip()
    
    /// Called after the stroke animation has ended
    func didEndStrokeSelectorAnimation()
    
    /// Called to ask if stroke selector animation should be shown
    ///
    /// - Returns: Bool for animation
    func editorShouldShowStrokeSelectorAnimation() -> Bool
    
    /// Called after the confirm button was tapped
    func didConfirmDrawing()
    
    /// Called when the color selector is panned
    ///
    /// - Parameter point: location to take the color from
    /// - Returns: Color from image
    func getColor(from point: CGPoint) -> UIColor
    
    /// Called when the color selector appears
    func didStartColorSelection()
    
    /// Called when the color selector starts its movement
    func didStartMovingColorSelector()
    
    /// Called when the color selector is released
    func didEndColorSelection()
}

/// Constants for Drawing Controller
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let defaultColor: UIColor = KanvasColors.shared.drawingDefaultColor
    static let numPointsPerLine: Int = 3
}

private enum DrawingMode {
    case draw
    case erase
    
    var blendMode: CGBlendMode {
        switch self {
        case .draw:
            return .normal
        case .erase:
            return .clear
        }
    }
}

/// Controller for handling the drawing menu.
final class DrawingController: UIViewController, DrawingViewDelegate, StrokeSelectorControllerDelegate, TextureSelectorControllerDelegate, ColorPickerControllerDelegate, ColorCollectionControllerDelegate, ColorSelectorControllerDelegate {
    
    weak var delegate: DrawingControllerDelegate?
    
    private lazy var drawingView: DrawingView = {
        let view = DrawingView()
        view.delegate = self
        return view
    }()
    
    private lazy var strokeSelectorController: StrokeSelectorController = {
        let controller = StrokeSelectorController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var textureSelectorController: TextureSelectorController = {
        let controller = TextureSelectorController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var colorPickerController: ColorPickerController = {
        let controller = ColorPickerController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var colorCollectionController: ColorCollectionController = {
        let controller = ColorCollectionController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var colorSelectorController: ColorSelectorController = {
        let controller = ColorSelectorController()
        controller.delegate = self
        return controller
    }()
    
    /// Confirm button location expressed in screen coordinates
    var confirmButtonLocation: CGPoint {
        return drawingView.confirmButtonLocation
    }
    
    var isEmpty: Bool {
        return drawingCollection.isEmpty
    }
    
    // Drawing
    var drawingLayer: CALayer?
    private var drawingCollection: [UIImage]
    private var drawingColor: UIColor
    private var mode: DrawingMode
    private var drawingPoints: [CGPoint]
    
    private var analyticsProvider: KanvasAnalyticsProvider?
    private var currentStrokeSize: Float {
        return Float(strokeSelectorController.strokeSize)
    }
    private var currentBrushType: KanvasBrushType {
        return textureSelectorController.texture.textureType
    }
    
    // MARK: Initializers
    
    init(analyticsProvider: KanvasAnalyticsProvider?) {
        self.analyticsProvider = analyticsProvider

        drawingCollection = []
        drawingColor = Constants.defaultColor
        mode = .draw
        drawingPoints = []
        
        super.init(nibName: .none, bundle: .none)
        setEyeDropperColor(Constants.defaultColor)
        setStrokeCircleColor(Constants.defaultColor)
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

        load(childViewController: strokeSelectorController, into: drawingView.strokeSelectorContainer)
        load(childViewController: textureSelectorController, into: drawingView.textureSelectorContainer)
        load(childViewController: colorPickerController, into: drawingView.colorPickerSelectorContainer)
        load(childViewController: colorCollectionController, into: drawingView.colorCollection)
        load(childViewController: colorSelectorController, into: drawingView.colorSelectorContainer)
    }
    
    // MARK: - View
    
    private func setUpView() {
        drawingView.alpha = 0
    }

    /// Tell the view that the rendering rectangle has changed.
    func didRenderRectChange(rect: CGRect) {
        drawingView.didRenderRectChange(rect: rect)
    }
    
    // MARK: - Drawing
    
    /// Sets the initial point for a line
    ///
    /// - Parameter point: location from which the line will start
    private func startLineDrawing(on point: CGPoint) {
        drawingPoints = [point]
    }
    
    /// Draws a line to a specified point
    ///
    /// - Parameter point: location where the line ends
    private func drawLine(to point: CGPoint) {
        if drawingPoints.count >= Constants.numPointsPerLine {
            drawingPoints.removeFirst(drawingPoints.count - (Constants.numPointsPerLine - 1))
        }
        drawingPoints.append(point)
        guard drawingPoints.count == Constants.numPointsPerLine else {
            return
        }

        let rect = drawingView.drawingCanvas.bounds
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        drawingView.temporalImageView.image?.draw(in: rect)

        let texture = textureSelectorController.texture
        let strokeSize = strokeSelectorController.getStrokeSize(minimum: texture.minimumStroke, maximum: texture.maximumStroke)
        texture.drawLine(context: context, points: drawingPoints, size: strokeSize, blendMode: mode.blendMode, color: drawingColor)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            drawingView.temporalImageView.image = image
            drawingLayer?.contents = image.cgImage
        }
        UIGraphicsEndImageContext()
    }
    
    /// Saves the drawing state and copies it to the layer
    private func endLineDrawing() {
        let rect = drawingView.drawingCanvas.bounds
        UIGraphicsBeginImageContext(rect.size)
        drawingView.temporalImageView.image?.draw(in: rect, blendMode: .normal, alpha: 1.0)
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            drawingCollection.append(image)
            drawingLayer?.contents = image.cgImage
        }
        UIGraphicsEndImageContext()
        drawingPoints = []
    }
    
    /// Draws a point on a specified point
    private func drawPoint(on point: CGPoint) {
        let rect = drawingView.drawingCanvas.bounds
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        drawingView.temporalImageView.image?.draw(in: rect)
        
        let texture = textureSelectorController.texture
        let strokeSize = strokeSelectorController.getStrokeSize(minimum: texture.minimumStroke, maximum: texture.maximumStroke)
        texture.drawPoint(context: context, on: point, size: strokeSize, blendMode: mode.blendMode, color: drawingColor)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            drawingView.temporalImageView.image = image
            drawingCollection.append(image)
            drawingLayer?.contents = image.cgImage
        }
        UIGraphicsEndImageContext()
    }
    
    /// Paints the complete background with a color
    private func fillBackground() {
        let rect = drawingView.drawingCanvas.bounds
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        drawingView.temporalImageView.image?.draw(in: rect)
        
        context.setBlendMode(mode.blendMode)
        context.setFillColor(drawingColor.cgColor)
        context.fill(rect)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            drawingView.temporalImageView.image = image
            drawingCollection.append(image)
            drawingLayer?.contents = image.cgImage
        }
        UIGraphicsEndImageContext()
    }
    
    /// Sets a new color for drawing
    ///
    /// - Parameter color: the new color for drawing
    private func setDrawingColor(_ color: UIColor, addToColorCollection: Bool = false) {
        drawingColor = color
        mode = .draw
        changeEraseIcon(selected: false)
        
        if addToColorCollection {
            colorCollectionController.addColor(color)
        }
    }
    
    /// Takes the drawing back to a previous state
    func undo() {
        guard drawingCollection.count > 0 else { return }
        drawingCollection.removeLast()
        drawingView.temporalImageView.image = drawingCollection.last
        drawingLayer?.contents = drawingCollection.last?.cgImage
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
    
    /// Shows or hides the overlay for the stroke selector
    ///
    /// - Parameter show: true to show, false to hide
    /// - Parameter animate: whether the UI update is animated
    private func showOverlay(_ show: Bool, animate: Bool = true) {
        drawingView.showOverlay(show, animate: animate)
    }
    
    /// shows or hides the drawing layer
    ///
    /// - Parameter show: true to show, false to hide
    private func showDrawingLayer(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.drawingLayer?.opacity = show ? 1 : 0
        }
    }
    
    /// Enables or disables the user interaction on the view
    ///
    /// - Parameter enable: true to enable, false to disable
    private func enableView(_ enable: Bool) {
        drawingView.enableView(enable)
    }
    
    /// Enables or disables the user interaction on the drawing canvas
    ///
    /// - Parameter enable: true to enable, false to disable
    private func enableDrawingCanvas(_ enable: Bool) {
        drawingView.enableDrawingCanvas(enable)
    }
    
    // MARK: - StrokeSelectorControllerDelegate
    
    func didAnimationStart() {
        enableView(false)
        showOverlay(true, animate: false)
    }
    
    func didAnimationEnd() {
        showOverlay(false, animate: true)
        enableView(true)
    }

    func didStrokeChange(percentage: CGFloat) {
        analyticsProvider?.logEditorDrawingChangeStrokeSize(strokeSize: currentStrokeSize)
    }

    // MARK: - Texture SelectorControllerDelegate

    func didSelectTexture(textureType: KanvasBrushType) {
        analyticsProvider?.logEditorDrawingChangeBrush(brushType: currentBrushType)
    }
    
    // MARK: - ColorPickerControllerDelegate
    
    func didSelectColor(_ color: UIColor, definitive: Bool) {
        setEyeDropperColor(color)
        setStrokeCircleColor(color)
        setDrawingColor(color, addToColorCollection: definitive)
        if definitive {
            analyticsProvider?.logEditorDrawingChangeColor(selectionTool: .gradient)
        }
    }
    
    // MARK: - DrawingViewDelegate
    
    func didTapDrawingCanvas(recognizer: UITapGestureRecognizer) {
        let currentPoint = recognizer.location(in: recognizer.view)
        drawPoint(on: currentPoint)
        logDraw(.tap)
    }
    
    func didPanDrawingCanvas(recognizer: UIPanGestureRecognizer) {
        let currentPoint = recognizer.location(in: recognizer.view)
        switch recognizer.state {
        case .began:
            startLineDrawing(on: currentPoint)
        case .changed:
            drawLine(to: currentPoint)
        case .ended:
            endLineDrawing()
            logDraw(.stroke)
        case .possible, .failed, .cancelled:
            break
        @unknown default:
            break
        }
    }
    
    func didLongPressDrawingCanvas(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            fillBackground()
            logDraw(.fill)
        case .changed, .ended, .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    func didDismissTooltip() {
        delegate?.didDismissColorSelectorTooltip()
    }
    
    func didTapConfirmButton() {
        textureSelectorController.showSelector(false)
        delegate?.didConfirmDrawing()
    }
    
    func didTapUndoButton() {
        undo()
        analyticsProvider?.logEditorDrawingUndo()
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

    func didTapColorPickerButton() {
        showBottomMenu(false)
        textureSelectorController.showSelector(false)
        showColorPickerContainer(true)
    }
    
    func didTapEyeDropper() {
        colorSelectorController.circleInitialLocation = drawingView.colorSelectorOrigin
        colorSelectorController.resetLocation()
        showColorPickerContainer(false)
        showTopButtons(false)
        resetColorSelectorColor()
        colorSelectorController.show(true)
        enableDrawingCanvas(false)
    }
    
    // MARK: - Private utilities
    
    // MARK: - Color Picker
    
    /// Sets a new color for the eye dropper button background
    ///
    /// - Parameter color: new color for the eye dropper button
    private func setEyeDropperColor(_ color: UIColor) {
        drawingView.setEyeDropperColor(color)
    }
    
    /// Sets a new color for the circle in the stroke selector
    ///
    /// - Parameter color: the new color to be applied
    private func setStrokeCircleColor(_ color: UIColor) {
        strokeSelectorController.tintStrokeCircle(color: color)
    }
    
    /// Changes the color of the color selector to the one from its initial position
    private func resetColorSelectorColor() {
        let color = getColor(at: colorSelectorController.circleInitialLocation)
        colorSelectorController.setColor(color)
        setDrawingColor(color)
    }

    // MARK: - ColorCollectionControllerDelegate
    
    func didSelectColor(_ color: UIColor) {
        setEyeDropperColor(color)
        setStrokeCircleColor(color)
        setDrawingColor(color)
        analyticsProvider?.logEditorDrawingChangeColor(selectionTool: .swatch)
    }
    
    // MARK: - ColorSelectorControllerDelegate
    
    /// Gets the color of a certain point of the media playing on the background
    ///
    /// - Parameter point: the location to take the color from
    /// - Returns: the color of the pixel
    func getColor(at point: CGPoint) -> UIColor {
        guard let delegate = delegate else { return .black }
        return delegate.getColor(from: point)
    }
    
    func shouldShowTooltip() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowColorSelectorTooltip()
    }
    
    func didShowCircle() {
        delegate?.didStartColorSelection()
    }
    
    func didStartMovingCircle() {
        delegate?.didStartMovingColorSelector()
    }
    
    func didEndMovingCircle(color: UIColor) {
        setEyeDropperColor(color)
        setStrokeCircleColor(color)
        setDrawingColor(color, addToColorCollection: true)
        
        showColorPickerContainer(true)
        showTopButtons(true)
        enableDrawingCanvas(true)
        analyticsProvider?.logEditorDrawingChangeColor(selectionTool: .eyedropper)
        delegate?.didEndColorSelection()
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
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.drawingView.alpha = show ? 1 : 0
        }, completion: { _ in
            if show && self.delegate?.editorShouldShowStrokeSelectorAnimation() == true {
                self.strokeSelectorController.showAnimation()
                self.delegate?.didEndStrokeSelectorAnimation()
            }
        })
    }
    
    /// shows or hides the confirm button
    ///
    /// - Parameter show: true to show, false to hide
    func showConfirmButton(_ show: Bool) {
        drawingView.showConfirmButton(show)
    }
    
    /// shows or hides the drawing canvas
    ///
    /// - Parameter show: true to show, false to hide
    func showCanvas(_ show: Bool) {
        drawingView.showCanvas(show)
        showDrawingLayer(show)
    }

    func logDraw(_ drawType: KanvasDrawingAction) {
        switch mode {
        case .draw:
            analyticsProvider?.logEditorDrawStroke(brushType: currentBrushType, strokeSize: currentStrokeSize, drawType: drawType)
        case .erase:
            analyticsProvider?.logEditorDrawingEraser(brushType: currentBrushType, strokeSize: currentStrokeSize, drawType: drawType)
        }
    }
}
