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
    func shouldShowTooltip() -> Bool
    
    /// Called after the color selecter tooltip is dismissed
    func didDismissTooltip()
    
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

/// Controller for handling the color selecter on the drawing menu.
final class ColorSelecterController: UIViewController, ColorSelecterViewDelegate {
    
    weak var delegate: ColorSelecterControllerDelegate?
    
    var circleInitialLocation: CGPoint {
        get {
            return colorSelecterView.circleInitialLocation
        }
        set {
            colorSelecterView.circleInitialLocation = newValue
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
    
    func didDismissTooltip() {
        delegate?.didDismissTooltip()
    }
    
    /// Shows or hides the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func show(_ show: Bool) {
        colorSelecterView.show(show)
        
        if delegate?.shouldShowTooltip() == true {
            colorSelecterView.showOverlay(true)
            colorSelecterView.showTooltip(true)
        }
    }
    
    /// Sets a new color for the color selecter background
    ///
    /// - Parameter color: new color for the color selecter
    func setColor(_ color: UIColor) {
        colorSelecterView.setColor(color)
    }
    
    /// Takes the color selecter back to its initial position
    func resetLocation() {
        colorSelecterView.moveCircle(to: colorSelecterView.circleInitialLocation)
        colorSelecterView.transformCircle(CGAffineTransform(scaleX: 0, y: 0))
    }
    
    /// Changes the background color of the color selecter to the one from its initial position
    func resetColorSelecterColor() {
        let color = getColor(at: circleInitialLocation)
        colorSelecterView.setColor(color)
    }
    
    // MARK: - Private utilities
    
    /// Changes the location of the color selecter to the location of the user's finger
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Returns: the new location of the color selecter
    private func moveCircle(recognizer: UIPanGestureRecognizer) -> CGPoint {
        let translation = recognizer.translation(in: colorSelecterView)
        let point = CGPoint(x: circleInitialLocation.x + translation.x, y: circleInitialLocation.y + translation.y)
        colorSelecterView.moveCircle(to: point)
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
    
    // MARK: - Circle movement
    
    func didPanCircle(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            delegate?.didStartColorSelection()
            if delegate?.shouldShowTooltip() == true {
                colorSelecterView.showTooltip(false)
                colorSelecterView.showOverlay(false)
            }
        case .changed:
            let currentLocation = moveCircle(recognizer: recognizer)
            let color = getColor(at: currentLocation)
            colorSelecterView.setColor(color)
        case .ended, .failed, .cancelled:
            let currentLocation = moveCircle(recognizer: recognizer)
            let color = getColor(at: currentLocation)
            show(false)
            delegate?.didEndColorSelection(color: color)
        case .possible:
            break
        @unknown default:
            break
        }
    }
}
