//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for text canvas methods

protocol TextCanvasDelegate: class {
    /// Called when a text is tapped
    ///
    /// - Parameter option: text style options
    /// - Parameter transformations: transformations for the view
    func didTapText(options: TextOptions, transformations: ViewTransformations)
}

/// View that contains the collection of text views
final class TextCanvas: IgnoreTouchesView, UIGestureRecognizerDelegate {
    
    weak var delegate: TextCanvasDelegate?
    
    // Values from which the different gestures start
    private var originTransformations: ViewTransformations = ViewTransformations()
    
    /// Adds a new text view
    ///
    /// - Parameter option: text style options
    /// - Parameter transformations: transformations for the view
    /// - Parameter size: size of the text view
    func addText(options: TextOptions, transformations: ViewTransformations, size: CGSize) {
        let textView = MovableTextView(options: options, transformations: transformations)
        textView.isUserInteractionEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: size.height),
            textView.widthAnchor.constraint(equalToConstant: size.width),
            textView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(textTapped(recognizer:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(textPanned(recognizer:)))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(textRotated(recognizer:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(textPinched(recognizer:)))
        
        tapRecognizer.delegate = self
        panRecognizer.delegate = self
        rotationRecognizer.delegate = self
        pinchRecognizer.delegate = self
        
        textView.addGestureRecognizer(tapRecognizer)
        textView.addGestureRecognizer(panRecognizer)
        textView.addGestureRecognizer(rotationRecognizer)
        textView.addGestureRecognizer(pinchRecognizer)
    }
    
    
    // MARK: - Gesture recognizers
    
    @objc func textTapped(recognizer: UITapGestureRecognizer) {
        guard let view = recognizer.view as? MovableTextView else { return }
        delegate?.didTapText(options: view.options, transformations: view.transformations)
        view.removeFromSuperview()
    }
    
    @objc func textRotated(recognizer: UIRotationGestureRecognizer) {
        guard let view = recognizer.view as? MovableTextView else { return }

        switch recognizer.state {
        case .began:
            originTransformations.rotation = view.rotation
        case .changed, .ended:
            let newRotation = originTransformations.rotation + recognizer.rotation
            view.rotation = newRotation
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func textPanned(recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view as? MovableTextView else { return }
        
        switch recognizer.state {
        case .began:
            originTransformations.position = view.position
        case .changed, .ended:
            let translation = recognizer.translation(in: self)
            let newPosition = CGPoint(x: originTransformations.position.x + translation.x, y: originTransformations.position.y + translation.y)
            view.position = newPosition
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func textPinched(recognizer: UIPinchGestureRecognizer) {
        guard let view = recognizer.view as? MovableTextView else { return }
        
        switch recognizer.state {
        case .began:
            originTransformations.scale = view.scale
        case .changed, .ended:
            let newScale = originTransformations.scale * recognizer.scale
            view.scale = newScale
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Public interface
    
    /// Saves the current view into its layer
    func updateLayer() {
        layer.contents = asImage().cgImage
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
