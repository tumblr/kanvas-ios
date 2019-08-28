//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

final class MovableTextView: UIView {
    
    private var rotation: CGFloat = 0.0
    private var position: CGPoint = .zero
    private var scale: CGFloat = 1.0
    
    init(text: String) {
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
        textView.text = text
        textView.add(into: self)
    }
    
    // MARK: - Properties
    
    func setRotation(_ newRotation: CGFloat) {
        rotation = newRotation
        updateTransform()
    }
    
    func getRotation() -> CGFloat {
        return rotation
    }
    
    func setScale(_ newScale: CGFloat) {
        scale = newScale
        updateTransform()
    }
    
    func getScale() -> CGFloat {
        return scale
    }
    
    func setPosition(_ newPosition: CGPoint) {
        position = newPosition
        updateTransform()
    }
    
    func getPosition() -> CGPoint {
        return position
    }
    
    // MARK: - Transforms
    
    private func updateTransform() {
        transform = CGAffineTransform(scaleX: scale, y: scale)
            .concatenating(CGAffineTransform(rotationAngle: rotation))
            .concatenating(CGAffineTransform(translationX: position.x, y: position.y))
    }
}
