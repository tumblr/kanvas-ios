//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for MovableTextView
private struct Constants {
    static let animationDuration: TimeInterval = 0.35
    static let deletionScale: CGFloat = 0.9
    static let opaqueAlpha: CGFloat = 1
    static let translucentAlpha: CGFloat = 0.8
}

/// A TextView wrapped in a UIView that can be rotated, moved and scaled
final class MovableTextView: UIView {
    
    private let innerTextView: UITextView
    
    /// Current rotation angle
    var rotation: CGFloat {
        didSet {
            applyTransform()
        }
    }
    
    /// Current position from the origin point
    var position: CGPoint {
        didSet {
            applyTransform()
        }
    }
    
    /// Current scale factor
    var scale: CGFloat {
        didSet {
            applyTransform()
        }
    }
    
    var options: TextOptions {
        get {
            return innerTextView.options
        }
        set {
            innerTextView.options = newValue
        }
    }
    
    var transformations: ViewTransformations {
        return ViewTransformations(position: position, scale: scale, rotation: rotation)
    }
    
    init(options: TextOptions, transformations: ViewTransformations) {
        self.innerTextView = UITextView()
        self.position = transformations.position
        self.scale = transformations.scale
        self.rotation = transformations.rotation
        super.init(frame: .zero)
        
        setupTextView(options: options)
        applyTransform()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    /// Sets up the inner text view
    ///
    /// - Parameter option: text style options
    private func setupTextView(options: TextOptions) {
        innerTextView.isUserInteractionEnabled = false
        innerTextView.backgroundColor = .clear
        innerTextView.options = options
        innerTextView.add(into: self)
    }
    
    
    // MARK: - View life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        innerTextView.setScaleFactor(scale)
    }

    // MARK: - Transforms
    
    /// Updates the scaling, rotation and position transformations
    private func applyTransform() {
        innerTextView.setScaleFactor(scale)
        
        transform = CGAffineTransform(scaleX: scale, y: scale)
            .concatenating(CGAffineTransform(rotationAngle: rotation))
            .concatenating(CGAffineTransform(translationX: position.x, y: position.y))
    }
    
    /// MARK: - Public interface
    
    /// Makes the view opaque
    func fadeIn() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.alpha = Constants.opaqueAlpha
        }
    }
    
    /// Makes the view translucent
    func fadeOut() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.alpha = Constants.translucentAlpha
        }
    }
    
    
    /// Removes the view from its superview with an animation
    func remove() {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.innerTextView.transform = CGAffineTransform(scaleX: Constants.deletionScale, y: Constants.deletionScale)
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}

private extension UITextView {
    
    /// Sets a new scale factor to update the quality of the text. This value represents how content in the view is mapped
    /// from the logical coordinate space (measured in points) to the device coordinate space (measured in pixels).
    /// For example, if the scale factor is 2.0, 2 pixels will be used to draw each point of the frame.
    ///
    /// - Parameter scaleFactor: the new scale factor. The value will be internally multiplied by the native scale of the device.
    /// Values must be higher than 1.0.
    func setScaleFactor(_ scaleFactor: CGFloat) {
        guard scaleFactor >= 1.0 else { return }
        textInputView.contentScaleFactor = scaleFactor * UIScreen.main.nativeScale
    }
}
