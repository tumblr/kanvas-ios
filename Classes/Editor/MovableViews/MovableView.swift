//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for tapping a movable view
protocol MovableViewDelegate: class {
    /// Callback for when a movable view with text is tapped
    ///
    /// - Parameters
    ///  - movableView: the tapped movable view
    ///  - textView: the text view inside the movable view
    func didTapTextView(movableView: MovableView, textView: StylableTextView)
    
    /// Callback for when a movable view with an image is tapped
    ///
    /// - Parameters
    ///  - movableView: the tapped movable view
    ///  - imageView: the image view inside the movable view
    func didTapImageView(movableView: MovableView, imageView: StylableImageView)
    
    /// Callback for when a movable view with text is moved
    func didMoveTextView()
    
    /// Callback for when a movable view with an image is moved
    ///
    /// - Parameter imageView: the image view that was moved
    func didMoveImageView(_ imageView: StylableImageView)
    
    /// Callback for when a movable view with text is removed
    func didRemoveTextView()
    
    /// Callback for when a movable view with an image is removed
    ///
    /// - Parameter imageView: the image view that was removed
    func didRemoveImageView(_ imageView: StylableImageView)
}

/// Constants for MovableTextView
private struct Constants {
    static let animationDuration: TimeInterval = 0.35
    static let deletionScale: CGFloat = 0.9
    static let minimumSize: CGFloat = 50
    static let opaqueAlpha: CGFloat = 1
    static let translucentAlpha: CGFloat = 0.8
}

/// A wrapper for UIViews that can be rotated, moved and scaled
final class MovableView: UIView {
    
    weak var delegate: MovableViewDelegate?
    private let innerView: MovableViewInnerElement
    
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
    
    init(view innerView: MovableViewInnerElement, transformations: ViewTransformations) {
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
            self.onRemove()
        })
    }
    
    /// Called when the view is tapped
    func onTap() {
        if let textView = innerView as? StylableTextView {
            delegate?.didTapTextView(movableView: self, textView: textView)
        }
        else if let imageView = innerView as? StylableImageView {
            delegate?.didTapImageView(movableView: self, imageView: imageView)
        }
    }
    
    // Called when the view is moved
    func onMove() {
        if let _ = innerView as? StylableTextView {
            delegate?.didMoveTextView()
        }
        else if let imageView = innerView as? StylableImageView {
            delegate?.didMoveImageView(imageView)
        }
    }
    
    // Called when the view is removed
    func onRemove() {
        if let _ = innerView as? StylableTextView {
            delegate?.didRemoveTextView()
        }
        else if let imageView = innerView as? StylableImageView {
            delegate?.didRemoveImageView(imageView)
        }
    }
    
    // MARK: - Extended hit area
    
    /// Gets the largest side of the view
    private func getSize() -> CGFloat {
        return max(bounds.height, bounds.width) * scale
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if getSize() < Constants.minimumSize {
            return super.hitTest(point, with: event)
        }
        else if innerView.hitInsideShape(point: point) {
            return self
        }
        else {
            return nil
        }
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let offset = calculateHitAreaOffset()
        let relativeFrame = bounds
        let hitTestEdgeInsets = UIEdgeInsets(top: -offset,
                                             left: -offset,
                                             bottom: -offset,
                                             right: -offset)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    
    /// Calculates the hit area increment that the view will include
    /// when its size is modified.
    private func calculateHitAreaOffset() -> CGFloat {
        let offset: CGFloat
        let size = getSize()
        
        if size < Constants.minimumSize {
            offset = Constants.minimumSize - size
        }
        else {
            offset = 0
        }
        
        return offset
    }
}
