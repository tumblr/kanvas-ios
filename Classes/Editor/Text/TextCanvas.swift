//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct Constants {
    static let defaultPosition: CGPoint = .zero
    static let defaultScale: CGFloat = 1.0
    static let defaultRotation: CGFloat = 0.0
}

final class TextCanvas: IgnoreTouchesView {
    
    private var originPoint: CGPoint = Constants.defaultPosition
    private var originScale: CGFloat = Constants.defaultScale
    private var originRotation: CGFloat = Constants.defaultRotation
    
    func addText(options: TextOptions, size: CGSize) {
        let textView = MovableTextView(options: options, position: Constants.defaultPosition,
                                       scale: Constants.defaultScale, rotation: Constants.defaultRotation)
        textView.isUserInteractionEnabled = true
        addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: size.height),
            textView.widthAnchor.constraint(equalToConstant: size.width),
            textView.centerYAnchor.constraint(equalTo: centerYAnchor),
            textView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(textTapped(recognizer:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(textPanned(recognizer:)))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(textRotated(recognizer:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(textPinched(recognizer:)))
        
        textView.addGestureRecognizer(tapRecognizer)
        textView.addGestureRecognizer(panRecognizer)
        textView.addGestureRecognizer(rotationRecognizer)
        textView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    
    // MARK: - Gesture recognizers
    
    @objc func textTapped(recognizer: UITapGestureRecognizer) {
        // TO DO: Open editor
    }
    
    @objc func textRotated(recognizer: UIRotationGestureRecognizer) {
        guard let view = recognizer.view as? MovableTextView else { return }

        switch recognizer.state {
        case .began:
            originRotation = view.rotation
        case .changed, .ended:
            let newRotation = originRotation + recognizer.rotation
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
            originPoint = view.position
        case .changed, .ended:
            let translation = recognizer.translation(in: self)
            let newPosition = CGPoint(x: originPoint.x + translation.x, y: originPoint.y + translation.y)
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
            originScale = view.scale
        case .changed, .ended:
            let newScale = originScale * recognizer.scale
            view.scale = newScale
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Public interface
    
    func updateLayer() {
        layer.contents = asImage().cgImage
    }
}
