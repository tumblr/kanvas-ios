//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

final class TextCanvas: IgnoreTouchesView {
    
    private var originPoint: CGPoint = .zero
    private var originScale: CGFloat = 1.0
    private var originRotation: CGFloat = 0.0
    
    func add(text: String, size: CGSize) {
        let textView = MovableTextView(text: text)
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
            originRotation = view.getRotation()
        case .changed, .ended:
            let newRotation = originRotation + recognizer.rotation
            view.setRotation(newRotation)
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
            originPoint = view.getPosition()
        case .changed, .ended:
            let translation = recognizer.translation(in: self)
            let position = CGPoint(x: originPoint.x + translation.x, y: originPoint.y + translation.y)
            view.setPosition(position)
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
            originScale = view.getScale()
        case .changed, .ended:
            let scale = originScale * recognizer.scale
            view.setScale(scale)
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    
    // MARK: - Private utilities
    
    private func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    private func updateLayer() {
        layer.contents = asImage().cgImage
    }
}
