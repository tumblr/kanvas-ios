//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

final class MovableTextView: UIView {
    
    var rotation: CGFloat {
        didSet {
            updateTransform()
        }
    }
    
    var position: CGPoint {
        didSet {
            updateTransform()
        }
    }
    
    var scale: CGFloat {
        didSet {
            updateTransform()
        }
    }
    
    init(text: String, position: CGPoint, scale: CGFloat, rotation: CGFloat) {
        self.position = position
        self.scale = scale
        self.rotation = rotation
        super.init(frame: .zero)
        
        setupTextView(text: text)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupTextView(text: String) {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .clear
        textView.text = text
        textView.add(into: self)
    }
    
    // MARK: - Transforms
    
    private func updateTransform() {
        transform = CGAffineTransform(scaleX: scale, y: scale)
            .concatenating(CGAffineTransform(rotationAngle: rotation))
            .concatenating(CGAffineTransform(translationX: position.x, y: position.y))
    }
}
