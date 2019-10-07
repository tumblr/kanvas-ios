//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol ColorSelecterControllerDelegate: class {
    
    /// Called to ask if color selecter tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func editorShouldShowColorSelecterTooltip() -> Bool
    
    /// Called after the color selecter tooltip is dismissed
    func didDismissColorSelecterTooltip()
    
    /// Called when the color selecter is panned
    ///
    /// - Parameter point: location to take the color from
    /// - Returns: Color from image
    func getColor(at point: CGPoint) -> UIColor
    
    /// Called when the color selector is pressed
    func didStartColorSelection()

    /// Called when the color selector is released
    ///
    /// - Parameter color: selected color
    func didEndColorSelection(color: UIColor)
}

/// Constants for the color selecter controller
private struct ColorSelecterControllerConstants {
    
}

/// Controller for handling the color selecter on the drawing menu.
final class ColorSelecterController: UIViewController, ColorSelecterViewDelegate {
    
    weak var delegate: ColorSelecterControllerDelegate?
    
    var colorSelecterOrigin: CGPoint {
        get {
            return colorSelecterView.colorSelecterOrigin
        }
        set {
            colorSelecterView.colorSelecterOrigin = newValue
        }
    }
    
    private lazy var colorSelecterView: ColorSelecterView = {
        let view = ColorSelecterView()
        view.delegate = self
        return view
    }()
    
    init() {
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
        view = colorSelecterView
    }
    
    // MARK: - Public interface
    
    func didDismissColorSelecterTooltip() {
        delegate?.didDismissColorSelecterTooltip()
    }
    
    /// Shows or hides the tooltip above color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showTooltip(_ show: Bool) {
        colorSelecterView.showTooltip(show)
    }

    /// Shows or hides the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showColorSelecter(_ show: Bool) {
        colorSelecterView.showColorSelecter(show)
        
        if delegate?.editorShouldShowColorSelecterTooltip() == true {
            showOverlay(true)
            showTooltip(true)
        }
    }
    
    /// Sets a new color for the color selecter background
    ///
    /// - Parameter color: new color for the color selecter
    func setColorSelecterColor(_ color: UIColor) {
        colorSelecterView.setColorSelecterColor(color)
    }
    
    /// Takes the color selecter back to its initial position (same position as the eye dropper's)
    func resetColorSelecterLocation() {
        let initialPoint = colorSelecterView.colorSelecterOrigin
        colorSelecterView.moveColorSelecter(to: initialPoint)
        colorSelecterView.transformColorSelecter(CGAffineTransform(scaleX: 0, y: 0))
        
        //colorSelecterOrigin = initialPoint
    }
    
    /// Changes the background color of the color selecter to the one from its initial position
    func resetColorSelecterColor() {
        let color = getColor(at: colorSelecterOrigin)
        setColorSelecterColor(color)
    }
    
    // MARK: - Private utilities
    
    /// Changes the location of the color selecter to the location of the user's finger
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Returns: the new location of the color selecter
    private func moveColorSelecter(recognizer: UIPanGestureRecognizer) -> CGPoint {
        let translation = recognizer.translation(in: colorSelecterView)
        let point = CGPoint(x: colorSelecterOrigin.x + translation.x, y: colorSelecterOrigin.y + translation.y)
        colorSelecterView.moveColorSelecter(to: point)
        return point
    }
    
    /// Gets the color of a certain point of the media playing on the background
    ///
    /// - Parameter point: the location to take the color from
    /// - Returns: the color of the pixel
    private func getColor(at point: CGPoint) -> UIColor {
        guard let delegate = delegate else { return .black }
        return delegate.getColor(at: point)
    }
    
    /// Shows or hides the overlay of the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    /// - Parameter animate: whether the UI update is animated
    private func showOverlay(_ show: Bool, animate: Bool = true) {
        colorSelecterView.showOverlay(show, animate: animate)
    }
    
    func didPanColorSelecter(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            delegate?.didStartColorSelection()
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
            showColorSelecter(false)
            delegate?.didEndColorSelection(color: color)
        case .possible:
            break
        @unknown default:
            break
        }
    }
}
