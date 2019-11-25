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

/// A wrapper for UIViews that can be rotated, moved and scaled
final class MovableView: UIView {
    
    let innerView: UIView
    
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
    
    var transformations: ViewTransformations {
        return ViewTransformations(position: position, scale: scale, rotation: rotation)
    }
    
    init(view innerView: UIView, transformations: ViewTransformations) {
        self.innerView = innerView
        self.position = transformations.position
        self.scale = transformations.scale
        self.rotation = transformations.rotation
        super.init(frame: .zero)
        
        setupInnerView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    /// Sets up the inner view
    private func setupInnerView() {
        innerView.add(into: self)
    }
    
    
    // MARK: - View life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        innerView.contentScaleFactor = scale
    }

    // MARK: - Transforms
    
    /// Updates the scaling, rotation and position transformations
    private func applyTransform() {
        innerView.contentScaleFactor = scale
        
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
    
    /// Moves the view to its defined position, size and angle
    func moveToDefinedPosition() {
        applyTransform()
    }
    
    /// Moves the view back to its initial position, size and angle
    func goBackToOrigin() {
        transform = .identity
    }
    
    /// Removes the view from its superview with an animation
    func remove() {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.innerView.transform = CGAffineTransform(scaleX: Constants.deletionScale, y: Constants.deletionScale)
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}
