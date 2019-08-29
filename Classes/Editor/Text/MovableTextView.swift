//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// A TextView wrapped in a UIView that can be rotated, moved and scaled
final class MovableTextView: UIView {
    
    /// Current rotation angle
    var rotation: CGFloat {
        didSet {
            updateTransform()
        }
    }
    
    /// Current position from the origin point
    var position: CGPoint {
        didSet {
            updateTransform()
        }
    }
    
    /// Current scale factor
    var scale: CGFloat {
        didSet {
            updateTransform()
        }
    }
    
    init(options: TextOptions, position: CGPoint, scale: CGFloat, rotation: CGFloat) {
        self.position = position
        self.scale = scale
        self.rotation = rotation
        super.init(frame: .zero)
        
        setupTextView(options: options)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    /// Sets up the inner text view
    ///
    /// - Parameter option: text style options
    private func setupTextView(options: TextOptions) {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .clear
        textView.options = options
        textView.add(into: self)
    }
    
    // MARK: - Transforms
    
    /// Updates the scaling, rotation and position transformations
    private func updateTransform() {
        transform = CGAffineTransform(scaleX: scale, y: scale)
            .concatenating(CGAffineTransform(rotationAngle: rotation))
            .concatenating(CGAffineTransform(translationX: position.x, y: position.y))
    }
}
