//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for movable text view methods
protocol MovableTextViewDelegate: class {
    /// Called when a touch event on the view begins
    ///
    /// - Parameter view: movable view where the touch occurred
    func didBeginTouches(view: MovableTextView)
    
    /// Called when the touch events on the view end
    func didEndTouches()
}

/// Constants for MovableTextView
private struct Constants {
    static let animationDuration: TimeInterval = 0.35
    static let deletionScale: CGFloat = 0.9
    static let opaqueAlpha: CGFloat = 1
    static let translucentAlpha: CGFloat = 0.8
}

/// A TextView wrapped in a UIView that can be rotated, moved and scaled
final class MovableTextView: UIView {
    
    weak var delegate: MovableTextViewDelegate?
    
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
    
    // MARK: - Transforms
    
    /// Updates the scaling, rotation and position transformations
    private func applyTransform() {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        delegate?.didBeginTouches(view: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let gestureRecognizers = gestureRecognizers else { return }
        let allRecognizersEnded = gestureRecognizers.allSatisfy { $0.state == .ended }
        if allRecognizersEnded {
            delegate?.didEndTouches()
        }
    }
}
