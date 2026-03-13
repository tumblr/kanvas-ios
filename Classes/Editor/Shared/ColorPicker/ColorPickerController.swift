//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol ColorPickerControllerDelegate: AnyObject {
    /// Called when a color is selected
    ///
    /// - Parameter color: the color just selected
    /// - Parameter definitive: whether the gesture has ended
    func didSelectColor(_ color: UIColor, definitive: Bool)
}

/// Constants for the color picker
private struct ColorPickerControllerConstants {
    static let animationDuration: TimeInterval = 0.25
}

/// Controller for handling the color picker gradient on the drawing menu.
final class ColorPickerController: UIViewController, ColorPickerViewDelegate {
    
    weak var delegate: ColorPickerControllerDelegate?
    
    private var selectedColor: UIColor = KanvasColors.shared.selectedPickerColor
    
    private lazy var colorPickerView: ColorPickerView = {
        let view = ColorPickerView()
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
        view = colorPickerView
    }
    
    
    // MARK: - ColorPickerViewDelegate
    
    func didTapSelector(recognizer: UITapGestureRecognizer) {
        selectColor(recognizer: recognizer, definitive: true)
    }
    
    func didPanSelector(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            selectColor(recognizer: recognizer)
        case .ended:
            selectColor(recognizer: recognizer, definitive: true)
        case .possible, .began, .cancelled, .failed:
            break
        @unknown default:
            break
        }
    }
    
    func didLongPressSelector(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            selectColor(recognizer: recognizer)
            colorPickerView.setLightToDarkColors(selectedColor)
        case .changed:
            selectColor(recognizer: recognizer)
        case .ended, .cancelled, .failed:
            selectColor(recognizer: recognizer, definitive: true)
            colorPickerView.setMainColors()
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Private utilities
    
    /// Selects the color being touched
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Parameter definitive: whether the gesture has ended
    private func selectColor(recognizer: UIGestureRecognizer, definitive: Bool = false) {
        guard let selectorView = recognizer.view else { return }
        let point = getSelectedGradientLocation(with: recognizer, in: selectorView)
        selectedColor = getColor(at: point.x + ColorPickerView.selectorPadding)
        delegate?.didSelectColor(selectedColor, definitive: definitive)
    }
    
    /// Gets the position of the color picker gradient that the user is touching.
    /// If the user goes beyond the limits of the view, the location is set to the limit of it.
    ///
    /// - Parameter recognizer: the gesture recognizer
    /// - Parameter view: the color picker gradient
    /// - Returns: point inside the color picker
    private func getSelectedGradientLocation(with recognizer: UIGestureRecognizer, in view: UIView) -> CGPoint {
        let dimensions = colorPickerView.getDimensions()
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
    
    /// Gets the color that has been selected from the color picker gradient
    ///
    /// - Parameter x: the horizontal position inside the gradient
    /// - Parameter defaultColor: a color to return in case of an error
    /// - Returns: the selected color
    private func getColor(at x: CGFloat, defaultColor: UIColor = .white) -> UIColor {
        let colorPickerPercent = x / colorPickerView.getDimensions().width
        
        let locations = colorPickerView.getGradientLocations()
        let colors = colorPickerView.getGradientColors()
        
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
}
