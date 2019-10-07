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
    func didPanColorSelecter(recognizer: UIPanGestureRecognizer)
    
    /// Called after the color selecter tooltip is dismissed
    func didDismissColorSelecterTooltip()
}

/// Constants for ColorSelecterView
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    
    // Overlay
    static let overlayColor = UIColor.black.withAlphaComponent(0.7)
    
    // Selector circle
    static let dropPadding: CGFloat = 18
    static let colorSelecterSize: CGFloat = 80
    static let colorSelecterAlpha: CGFloat = 0.65
    
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
    
    var colorSelecterOrigin: CGPoint
    
    // Color selecter
    private let colorSelecterContainer: UIView
    private let colorSelecter: CircularImageView
    private let upperDrop: ColorDrop
    private let lowerDrop: ColorDrop
    
    // Tooltip
    private var tooltip: EasyTipView?
    private let overlay: UIView
    
    init() {
        colorSelecterContainer = UIView()
        colorSelecter = CircularImageView()
        upperDrop = ColorDrop()
        lowerDrop = ColorDrop()
        overlay = UIView()
        colorSelecterOrigin = .zero
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
        setUpColorSelecterContainer()
        setUpColorSelecter()
        setUpColorSelecterDrop()
        setUpTooltip()
    }
    
    /// Sets up the translucent black view used for onboarding
    private func setUpOverlay() {
        overlay.accessibilityIdentifier = "Editor Overlay"
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
    
    private func setUpColorSelecterContainer() {
        colorSelecterContainer.backgroundColor = .clear
        colorSelecterContainer.accessibilityIdentifier = "Editor Color Selector Container"
        colorSelecterContainer.clipsToBounds = false
        colorSelecterContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorSelecterContainer)
        
        NSLayoutConstraint.activate([
            colorSelecterContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorSelecterContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorSelecterContainer.topAnchor.constraint(equalTo: topAnchor),
            colorSelecterContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        colorSelecterContainer.alpha = 0
    }
    
    /// Sets up the draggable circle that is shown when the eyedropper is pressed
    private func setUpColorSelecter() {
        colorSelecter.backgroundColor = UIColor.black.withAlphaComponent(Constants.colorSelecterAlpha)
        colorSelecter.layer.cornerRadius = Constants.colorSelecterSize / 2
        colorSelecter.accessibilityIdentifier = "Editor Color Selecter"
        colorSelecterContainer.addSubview(colorSelecter)
        
        NSLayoutConstraint.activate([
            colorSelecter.topAnchor.constraint(equalTo: topAnchor, constant: colorSelecterOrigin.y),
            colorSelecter.leadingAnchor.constraint(equalTo: leadingAnchor, constant: colorSelecterOrigin.x),
            colorSelecter.heightAnchor.constraint(equalToConstant: Constants.colorSelecterSize),
            colorSelecter.widthAnchor.constraint(equalToConstant: Constants.colorSelecterSize),
        ])
        
        colorSelecter.alpha = 0
        
        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.addTarget(self, action: #selector(colorSelecterPanned(recognizer:)))
        colorSelecter.addGestureRecognizer(panRecognizer)
    }
    
    private func setUpColorSelecterDrop() {
        setUpColorSelecterUpperDrop()
        setUpColorSelecterLowerDrop()
    }
    
    private func setUpColorSelecterUpperDrop() {
        upperDrop.accessibilityIdentifier = "Editor Color Selecter Upper Drop"
        colorSelecterContainer.addSubview(upperDrop)
        
        let verticalMargin = Constants.dropPadding
        NSLayoutConstraint.activate([
            upperDrop.bottomAnchor.constraint(equalTo: colorSelecter.topAnchor, constant: -verticalMargin),
            upperDrop.centerXAnchor.constraint(equalTo: colorSelecter.centerXAnchor),
            upperDrop.heightAnchor.constraint(equalToConstant: ColorDrop.defaultHeight),
            upperDrop.widthAnchor.constraint(equalToConstant: ColorDrop.defaultWidth),
        ])
        
        upperDrop.alpha = 0
    }
    
    private func setUpColorSelecterLowerDrop() {
        lowerDrop.accessibilityIdentifier = "Editor Color Selecter Lower Drop"
        lowerDrop.transform = CGAffineTransform(rotationAngle: .pi)
        colorSelecterContainer.addSubview(lowerDrop)
        
        let verticalMargin = Constants.dropPadding
        NSLayoutConstraint.activate([
            lowerDrop.topAnchor.constraint(equalTo: colorSelecter.bottomAnchor, constant: verticalMargin),
            lowerDrop.centerXAnchor.constraint(equalTo: colorSelecter.centerXAnchor),
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
        delegate?.didPanColorSelecter(recognizer: recognizer)
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
            tooltip?.show(animated: true, forView: colorSelecter, withinSuperview: self)
        }
        else {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.tooltip?.removeFromSuperview()
                self.tooltip?.dismiss()
            }
            delegate?.didDismissColorSelecterTooltip()
        }
    }
    
    /// Changes color selector location on screen
    ///
    /// - Parameter point: the new location
    func moveColorSelecter(to point: CGPoint) {
        print("L - move \(point)")
        colorSelecter.center = point
        
        let offset = Constants.dropPadding + (Constants.colorSelecterSize + ColorDrop.defaultHeight) / 2
        
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
    func transformColorSelecter(_ transform: CGAffineTransform) {
        colorSelecter.transform = transform
    }
    
    /// shows or hides the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    func showColorSelecter(_ show: Bool) {
        self.alpha = show ? 1 : 0
        self.colorSelecterContainer.alpha = show ? 1 : 0
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.colorSelecter.alpha = show ? 1 : 0
            self.colorSelecter.transform = .identity
            self.upperDrop.alpha = show ? 1 : 0
            self.lowerDrop.alpha = 0
        }
    }
    
    /// Sets a new color for the color selecter background
    ///
    /// - Parameter color: new color for the color selecter
    func setColorSelecterColor(_ color: UIColor) {
        colorSelecter.backgroundColor = color.withAlphaComponent(Constants.colorSelecterAlpha)
        upperDrop.innerColor = color
        lowerDrop.innerColor = color
    }
    
    /// shows or hides the overlay of the color selecter
    ///
    /// - Parameter show: true to show, false to hide
    /// - Parameter animate: whether the UI update is animated
    func showOverlay(_ show: Bool, animate: Bool = true) {
        if animate {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.overlay.alpha = show ? 1 : 0
            }
        }
        else {
            self.overlay.alpha = show ? 1 : 0
        }
    }

}
