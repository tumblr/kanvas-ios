//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol ColorSelectorControllerDelegate: AnyObject {
    
    /// Called to ask if tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func shouldShowTooltip() -> Bool
    
    /// Called after the tooltip is dismissed
    func didDismissTooltip()
    
    /// Called when the selection circle is panned
    ///
    /// - Parameter point: location to take the color from
    /// - Returns: Color from image
    func getColor(at point: CGPoint) -> UIColor
    
    /// Called when the selection circle appears
    func didShowCircle()
    
    /// Called when the selection circle is starts its movement
    func didStartMovingCircle()

    /// Called when the selection circle is released
    ///
    /// - Parameter color: selected color
    func didEndMovingCircle(color: UIColor)
}

/// Controller for handling the color selector in the drawing menu.
final class ColorSelectorController: UIViewController, ColorSelectorViewDelegate {
    
    weak var delegate: ColorSelectorControllerDelegate?
    
    var circleInitialLocation: CGPoint {
        get {
            return colorSelectorView.circleInitialLocation
        }
        set {
            colorSelectorView.circleInitialLocation = newValue
        }
    }
    
    private lazy var colorSelectorView: ColorSelectorView = {
        let view = ColorSelectorView()
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
        view = colorSelectorView
    }
    
    // MARK: - Public interface
    
    /// Shows or hides the color Selector
    ///
    /// - Parameter show: true to show, false to hide
    func show(_ show: Bool) {
        colorSelectorView.show(show)
        
        if delegate?.shouldShowTooltip() == true {
            colorSelectorView.showOverlay(true)
            colorSelectorView.showTooltip(true)
        }
        
        if show {
            delegate?.didShowCircle()
        }
    }
    
    /// Sets a new color for the color circle and drops
    ///
    /// - Parameter color: new color for the color Selector
    func setColor(_ color: UIColor) {
        colorSelectorView.setColor(color)
    }
    
    /// Takes the selection circle back to its initial position
    func resetLocation() {
        colorSelectorView.moveCircle(to: colorSelectorView.circleInitialLocation)
        colorSelectorView.transformCircle(CGAffineTransform(scaleX: 0, y: 0))
    }
    
    /// Changes the color of the selection circle to the one from the initial position
    func resetColor() {
        let color = getColor(at: circleInitialLocation)
        colorSelectorView.setColor(color)
    }
    
    // MARK: - Private utilities
    
    /// Changes the location of the color Selector to the location of the user's finger
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Returns: the new location of the color Selector
    private func moveCircle(recognizer: UIPanGestureRecognizer) -> CGPoint {
        let translation = recognizer.translation(in: colorSelectorView)
        let point = CGPoint(x: circleInitialLocation.x + translation.x, y: circleInitialLocation.y + translation.y)
        colorSelectorView.moveCircle(to: point)
        return point
    }
    
    /// Gets the color of a certain point of the background
    ///
    /// - Parameter point: the location to take the color from
    /// - Returns: the color of the pixel
    private func getColor(at point: CGPoint) -> UIColor {
        guard let delegate = delegate else { return .black }
        return delegate.getColor(at: point)
    }
    
    // MARK: - ColorSelectorViewDelegate
    
    func didPanCircle(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            delegate?.didStartMovingCircle()
            if delegate?.shouldShowTooltip() == true {
                colorSelectorView.showTooltip(false)
                colorSelectorView.showOverlay(false)
            }
        case .changed:
            let currentLocation = moveCircle(recognizer: recognizer)
            let color = getColor(at: currentLocation)
            colorSelectorView.setColor(color)
        case .ended, .failed, .cancelled:
            let currentLocation = moveCircle(recognizer: recognizer)
            let color = getColor(at: currentLocation)
            show(false)
            delegate?.didEndMovingCircle(color: color)
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    func didDismissTooltip() {
        delegate?.didDismissTooltip()
    }
}
