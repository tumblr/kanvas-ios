//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import SharedUI

/// Protocol for ColorSelecterView
protocol ColorSelecterViewDelegate: class {
    
    /// Called when the color selecter is panned
    ///
    /// - Parameter recognizer: the pan gesture recognizer
    func didPanCircle(recognizer: UIPanGestureRecognizer)
    
    /// Called after the color selecter tooltip is dismissed
    func didDismissTooltip()
}

/// Constants for ColorSelecterView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    
    // Overlay
    static let overlayColor = UIColor.black.withAlphaComponent(0.7)
    
    // Selector circle
    static let dropPadding: CGFloat = 18
    static let circleSize: CGFloat = 80
    static let circleAlpha: CGFloat = 0.65
    
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

/// View for ColorSelecterView
final class ColorSelecterView: UIView {

    weak var delegate: ColorSelecterViewDelegate?
    
    var circleInitialLocation: CGPoint
    
    // Color selecter
    private let container: UIView
    private let selectorCircle: CircularImageView
    private let upperDrop: ColorDrop
    private let lowerDrop: ColorDrop
    
    // Tooltip
    private var tooltip: EasyTipView?
    private let overlay: UIView
    
    init() {
        container = UIView()
        selectorCircle = CircularImageView()
        upperDrop = ColorDrop()
        lowerDrop = ColorDrop()
        overlay = UIView()
        circleInitialLocation = .zero
        super.init(frame: .zero)
        
        setUpViews()
        alpha = 0
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
        setUpOverlay()
        setUpContainer()
        setUpSelectorCircle()
        setUpDrop()
        setUpTooltip()
    }
    
    /// Sets up the translucent black view used for onboarding
    private func setUpOverlay() {
        overlay.accessibilityIdentifier = "Overlay"
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.clipsToBounds = true
        overlay.backgroundColor = Constants.overlayColor
        addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        overlay.alpha = 0
    }
    
    private func setUpContainer() {
        container.backgroundColor = .clear
        container.accessibilityIdentifier = "Container"
        container.clipsToBounds = false
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        container.alpha = 0
    }
    
    /// Sets up the draggable circle
    private func setUpSelectorCircle() {
        selectorCircle.backgroundColor = UIColor.black.withAlphaComponent(Constants.circleAlpha)
        selectorCircle.layer.cornerRadius = Constants.circleSize / 2
        selectorCircle.accessibilityIdentifier = "Selector Circle"
        container.addSubview(selectorCircle)
        
        NSLayoutConstraint.activate([
            selectorCircle.topAnchor.constraint(equalTo: topAnchor, constant: circleInitialLocation.y),
            selectorCircle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: circleInitialLocation.x),
            selectorCircle.heightAnchor.constraint(equalToConstant: Constants.circleSize),
            selectorCircle.widthAnchor.constraint(equalToConstant: Constants.circleSize),
        ])
        
        selectorCircle.alpha = 0
        
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(colorSelecterPanned(recognizer:)))
        selectorCircle.addGestureRecognizer(panRecognizer)
    }
    
    private func setUpDrop() {
        setUpUpperDrop()
        setUpLowerDrop()
    }
    
    private func setUpUpperDrop() {
        upperDrop.accessibilityIdentifier = "Upper Drop"
        container.addSubview(upperDrop)
        
        let verticalMargin = Constants.dropPadding
        NSLayoutConstraint.activate([
            upperDrop.bottomAnchor.constraint(equalTo: selectorCircle.topAnchor, constant: -verticalMargin),
            upperDrop.centerXAnchor.constraint(equalTo: selectorCircle.centerXAnchor),
            upperDrop.heightAnchor.constraint(equalToConstant: ColorDrop.defaultHeight),
            upperDrop.widthAnchor.constraint(equalToConstant: ColorDrop.defaultWidth),
        ])
        
        upperDrop.alpha = 0
    }
    
    private func setUpLowerDrop() {
        lowerDrop.accessibilityIdentifier = "Lower Drop"
        lowerDrop.transform = CGAffineTransform(rotationAngle: .pi)
        container.addSubview(lowerDrop)
        
        let verticalMargin = Constants.dropPadding
        NSLayoutConstraint.activate([
            lowerDrop.topAnchor.constraint(equalTo: selectorCircle.bottomAnchor, constant: verticalMargin),
            lowerDrop.centerXAnchor.constraint(equalTo: selectorCircle.centerXAnchor),
            lowerDrop.heightAnchor.constraint(equalToConstant: ColorDrop.defaultHeight),
            lowerDrop.widthAnchor.constraint(equalToConstant: ColorDrop.defaultWidth),
        ])
        
        lowerDrop.alpha = 0
    }
    
    /// Sets up the tooltip that is shown on top of the color selecter
    private func setUpTooltip() {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.foregroundColor = Constants.tooltipForegroundColor
        preferences.drawing.backgroundColor = Constants.tooltipBackgroundColor
        preferences.drawing.arrowPosition = Constants.tooltipArrowPosition
        preferences.drawing.cornerRadius = Constants.tooltipCornerRadius
        preferences.drawing.arrowWidth = Constants.tooltipArrowWidth
        preferences.positioning.margin = Constants.tooltipMargin
        preferences.drawing.font = Constants.tooltipFont
        preferences.positioning.textVInset = Constants.tooltipVerticalTextInset
        preferences.positioning.textHInset = Constants.tooltipHorizontalTextInset
        
        let text = NSLocalizedString("Drag to select color", comment: "Color selecter tooltip for the Camera")
        tooltip = EasyTipView(text: text, preferences: preferences)
    }
    
    // MARK: - Gesture recognizers
    
    @objc func colorSelecterPanned(recognizer: UIPanGestureRecognizer) {
        delegate?.didPanCircle(recognizer: recognizer)
    }
    
    // MARK: - Private utilitites
    
    /// Changes upper drop location on screen
    ///
    /// - Parameter point: the new location
    private func moveUpperDrop(to point: CGPoint) {
        upperDrop.center = point
    }
    
    /// Changes lower drop location on screen
    ///
    /// - Parameter point: the new location
    private func moveLowerDrop(to point: CGPoint) {
        lowerDrop.center = point
    }

    
    // MARK: - Public interface
    
    /// shows or hides the tooltip above color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showTooltip(_ show: Bool) {
        if show {
            tooltip?.show(animated: true, forView: selectorCircle, withinSuperview: self)
        }
        else {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.tooltip?.removeFromSuperview()
                self.tooltip?.dismiss()
            }
            delegate?.didDismissTooltip()
        }
    }
    
    /// Changes color selector location on screen
    ///
    /// - Parameter point: the new location
    func moveCircle(to point: CGPoint) {
        selectorCircle.center = point
        
        let offset = Constants.dropPadding + (Constants.circleSize + ColorDrop.defaultHeight) / 2
        
        let upperDropLocation = CGPoint(x: point.x, y: point.y - offset)
        let lowerDropLocation = CGPoint(x: point.x, y: point.y + offset)
        moveUpperDrop(to: upperDropLocation)
        moveLowerDrop(to: lowerDropLocation)
        
        let topPoint = upperDrop.center.y - upperDrop.frame.height / 2
        let upperDropVisible = topPoint > 0
        upperDrop.alpha = upperDropVisible ? 1 : 0
        lowerDrop.alpha = upperDropVisible ? 0 : 1
    }
    
    /// Applies a transformation to the color selecter
    ///
    /// - Parameter transform: the transformation to apply
    func transformCircle(_ transform: CGAffineTransform) {
        selectorCircle.transform = transform
    }
    
    /// shows or hides the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func show(_ show: Bool) {
        self.alpha = show ? 1 : 0
        self.container.alpha = show ? 1 : 0
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.selectorCircle.alpha = show ? 1 : 0
            self.selectorCircle.transform = .identity
            self.upperDrop.alpha = show ? 1 : 0
            self.lowerDrop.alpha = 0
        }
    }
    
    /// Sets a new color for the color selecter background
    ///
    /// - Parameter color: new color for the color selecter
    func setColor(_ color: UIColor) {
        selectorCircle.backgroundColor = color.withAlphaComponent(Constants.circleAlpha)
        upperDrop.innerColor = color
        lowerDrop.innerColor = color
    }
    
    /// shows or hides the overlay of the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    /// - Parameter animate: whether the UI update is animated
    func showOverlay(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.overlay.alpha = show ? 1 : 0
        }
    }

}
