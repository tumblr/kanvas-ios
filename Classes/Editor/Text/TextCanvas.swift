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
    
    func add(text: String) {
        let label = MovableLabel()
        label.text = text
        label.backgroundColor = .white
        label.isUserInteractionEnabled = true
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 300),
            label.widthAnchor.constraint(equalToConstant: 300),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(textTapped(recognizer:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(textPanned(recognizer:)))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(textRotated(recognizer:)))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(textPinched(recognizer:)))
        
        label.addGestureRecognizer(tapRecognizer)
        label.addGestureRecognizer(panRecognizer)
        label.addGestureRecognizer(rotationRecognizer)
        label.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    
    // MARK: - Gesture recognizers
    
    @objc func textTapped(recognizer: UITapGestureRecognizer) {
        // TO DO: Open editor
    }
    
    @objc func textRotated(recognizer: UIRotationGestureRecognizer) {
        guard let view = recognizer.view as? MovableLabel else { return }

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
        guard let view = recognizer.view as? MovableLabel else { return }
        
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
        guard let view = recognizer.view as? MovableLabel else { return }
        
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
