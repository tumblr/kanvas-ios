//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol ColorPickerViewDelegate: AnyObject {
    /// Called when the selector is tapped
    ///
    /// - Parameter recognizer: the tap gesture recognizer
    func didTapSelector(recognizer: UITapGestureRecognizer)
    
    /// Called when the selector is panned
    ///
    /// - Parameter recognizer: the pan gesture recognizer
    func didPanSelector(recognizer: UIPanGestureRecognizer)
    
    /// Called when the selector is long pressed
    ///
    /// - Parameter recognizer: the long press gesture recognizer
    func didLongPressSelector(recognizer: UILongPressGestureRecognizer)
}

private struct ColorPickerViewConstants {
    static let animationDuration: TimeInterval = 0.25
    
    static let selectorPadding: CGFloat = 14
    static let selectorHeight: CGFloat = CircularImageView.size
    
    // Color picker gradient
    static let colorLocations: [NSNumber] = [0.0, 0.05, 0.2, 0.4, 0.64, 0.82, 0.95, 1.0]
    
    static let colors = KanvasColors.shared.colorPickerColors
}

/// View for ColorPickerController
final class ColorPickerView: IgnoreTouchesView {
    
    static let selectorPadding: CGFloat = ColorPickerViewConstants.selectorPadding
    
    weak var delegate: ColorPickerViewDelegate?
    
    private let selectorBackground: CircularImageView
    private let selectorPannableArea: UIView
    private let gradient: CAGradientLayer
    
    init() {
        selectorBackground = CircularImageView()
        selectorPannableArea = UIView()
        gradient = CAGradientLayer()
        super.init(frame: .zero)
        
        clipsToBounds = false
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
        setUpSelectorBackground()
        setUpColorPickerSelectorPannableArea()
    }
    
    /// Sets up the horizontal gradient view
    private func setUpSelectorBackground() {
        selectorBackground.accessibilityIdentifier = "Color Picker Selector Background"
        selectorBackground.layer.borderWidth = 0
        selectorBackground.backgroundColor = .clear
        selectorBackground.add(into: self)
        
        setUpGradient()
        setMainColors()
    }
    
    /// Sets up the gradient inside the color picker selector
    private func setUpGradient() {
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = selectorBackground.bounds
        selectorBackground.layer.insertSublayer(gradient, at: 0)
    }
    
    /// Sets the main colors in the color picker gradient
    func setMainColors() {
        gradient.colors = ColorPickerViewConstants.colors.map { $0.cgColor }
        gradient.locations = ColorPickerViewConstants.colorLocations
    }
    
    /// Sets the light-to-dark colors in the color picker gradient
    func setLightToDarkColors(_ mainColor: UIColor) {
        gradient.colors = [UIColor.white.cgColor, mainColor.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 0.5, 1.0]
    }
    
    /// Sets up the area of the color picker in which the user can pan
    private func setUpColorPickerSelectorPannableArea() {
        selectorPannableArea.accessibilityIdentifier = "Color Picker Selector Pannable Area"
        selectorPannableArea.translatesAutoresizingMaskIntoConstraints = false
        selectorBackground.addSubview(selectorPannableArea)
        
        NSLayoutConstraint.activate([
            selectorPannableArea.leadingAnchor.constraint(equalTo: selectorBackground.leadingAnchor, constant: ColorPickerViewConstants.selectorPadding),
            selectorPannableArea.trailingAnchor.constraint(equalTo: selectorBackground.trailingAnchor, constant: -ColorPickerViewConstants.selectorPadding),
            selectorPannableArea.bottomAnchor.constraint(equalTo: selectorBackground.bottomAnchor),
            selectorPannableArea.topAnchor.constraint(equalTo: selectorBackground.topAnchor),
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectorTapped(recognizer:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(selectorPanned(recognizer:)))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectorLongPressed(recognizer:)))
        selectorPannableArea.addGestureRecognizer(tapRecognizer)
        selectorPannableArea.addGestureRecognizer(panRecognizer)
        selectorPannableArea.addGestureRecognizer(longPressRecognizer)
    }
    
    // MARK: - Gesture Recognizers
    
    @objc func selectorTapped(recognizer: UITapGestureRecognizer) {
        delegate?.didTapSelector(recognizer: recognizer)
    }
    
    @objc func selectorPanned(recognizer: UIPanGestureRecognizer) {
        delegate?.didPanSelector(recognizer: recognizer)
    }
    
    @objc func selectorLongPressed(recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPressSelector(recognizer: recognizer)
    }
    
    
    // MARK: - Public interface
    
    /// Gets the color picker rectangle
    ///
    /// - Returns: frame of the color picker background
    func getDimensions() -> CGRect {
        return selectorBackground.frame
    }
    
    /// Gets the gradient colors
    ///
    /// - Returns: collection of colors
    func getGradientColors() -> [CGColor] {
        guard let colors = gradient.colors as? [CGColor] else { return [] }
        return colors
    }
    
    /// Gets the gradient color locations
    ///
    /// - Returns: collection of locations
    func getGradientLocations() -> [NSNumber] {
        guard let locations = gradient.locations else { return [] }
        return locations
    }
    
    // MARK: - Gradients
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateGradients()
    }
    
    private func updateGradients() {
        gradient.frame = selectorBackground.bounds
    }
}
