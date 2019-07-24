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
final class DrawingController: UIViewController, DrawingViewDelegate, StrokeSelectorControllerDelegate, ColorPickerControllerDelegate {
    
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
    
    private lazy var textureSelectorController = TextureSelectorController()
    
    private lazy var colorPickerController: ColorPickerController = {
        let controller = ColorPickerController()
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
        
        load(childViewController: strokeSelectorController, into: drawingView.strokeSelectorContainer)
        load(childViewController: textureSelectorController, into: drawingView.textureSelectorContainer)
        load(childViewController: colorPickerController, into: drawingView.colorPickerSelectorContainer)
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
    /// - Parameter animate: whether the UI update is animated
    private func showOverlay(_ show: Bool, animate: Bool = true) {
        drawingView.showOverlay(show, animate: animate)
    }
    
    /// Shows or hides the tooltip above color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showTooltip(_ show: Bool) {
        drawingView.showTooltip(show)
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
    
    // MARK: - ColorPickerControllerDelegate
    
    func didSelectColor(_ color: UIColor) {
        setEyeDropperColor(color)
        setDrawingColor(color)
    }
    
    // MARK: - DrawingViewDelegate
    
    func didDismissColorSelecterTooltip() {
        delegate?.didDismissColorSelecterTooltip()
    }
    
    func didTapConfirmButton() {
        textureSelectorController.showSelector(false)
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
    
    func didTapColorPickerButton() {
        showBottomMenu(false)
        textureSelectorController.showSelector(false)
        showColorPickerContainer(true)
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
    
    // MARK: - Color Picker
    
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
                self.strokeSelectorController.showAnimation()
                self.delegate?.didEndStrokeSelectorAnimation()
            }
        })
    }

}
