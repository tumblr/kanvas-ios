//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

final class TextCanvas: IgnoreTouchesView {
    
    private var lastRotation: CGFloat = 0
    private var originPoint: CGPoint = .zero
    private var originScale: CGFloat = 1.0
    
    func add(text: String) {
        let label = UILabel()
        label.text = text
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
        var originalRotation = CGFloat()
        
        switch recognizer.state {
        case .began:
            recognizer.rotation = lastRotation
            originalRotation = recognizer.rotation
        case .changed:
            let newRotation = recognizer.rotation + originalRotation
            recognizer.view?.transform = CGAffineTransform(rotationAngle: newRotation)
        case .ended:
            lastRotation = recognizer.rotation
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func textPanned(recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        switch recognizer.state {
        case .began:
            originPoint = view.center
        case .changed, .ended:
            let translation = recognizer.translation(in: self)
            let point = CGPoint(x: originPoint.x + translation.x, y: originPoint.y + translation.y)
            view.center = point
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func textPinched(recognizer: UIPinchGestureRecognizer) {
        guard let view = recognizer.view else { return }
        switch recognizer.state {
        case .began:
            originScale = view.contentScaleFactor
        case .changed, .ended:
            let scale = originScale * recognizer.scale
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
        
        let scale = recognizer.scale
        view.transform = CGAffineTransform(scaleX: scale, y: scale)
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
