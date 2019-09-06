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

/// Constants for the text canvas
private struct Constants {
    static let trashViewSize: CGFloat = 98
    static let trashViewBottomMargin: CGFloat = 93
}

/// View that contains the collection of text views
final class TextCanvas: IgnoreTouchesView, UIGestureRecognizerDelegate {
    
    weak var delegate: TextCanvasDelegate?
    
    private let trashView: UIView
    
    // Values from which the different gestures start
    private var originTransformations: ViewTransformations
    
    
    init() {
        trashView = UIView()
        originTransformations = ViewTransformations()
        super.init(frame: .zero)
        setUpTrashView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpTrashView() {
        trashView.accessibilityIdentifier = "Editor Text Trash View"
        trashView.translatesAutoresizingMaskIntoConstraints = false
        trashView.backgroundColor = .blue
        addSubview(trashView)
        
        NSLayoutConstraint.activate([
            trashView.heightAnchor.constraint(equalToConstant: Constants.trashViewSize),
            trashView.widthAnchor.constraint(equalToConstant: Constants.trashViewSize),
            trashView.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            trashView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -Constants.trashViewBottomMargin),
        ])
    }
    
    // MARK: - Public interface
    
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
            textView.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor)
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
    
    /// Saves the current view into its layer
    func updateLayer() {
        layer.contents = asImage().cgImage
    }
    
    // MARK: - Gesture recognizers
    
    @objc func textTapped(recognizer: UITapGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableTextView else { return }
        delegate?.didTapText(options: movableView.options, transformations: movableView.transformations)
        movableView.removeFromSuperview()
    }
    
    @objc func textRotated(recognizer: UIRotationGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableTextView else { return }

        switch recognizer.state {
        case .began:
            originTransformations.rotation = movableView.rotation
        case .changed, .ended:
            let newRotation = originTransformations.rotation + recognizer.rotation
            movableView.rotation = newRotation
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    var touchPosition: [CGPoint] = []
    
    @objc func textPanned(recognizer: UIPanGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableTextView else { return }
        
        switch recognizer.state {
        case .began:
            originTransformations.position = movableView.position
        case .changed:
            let newPosition = originTransformations.position + recognizer.translation(in: self)
            movableView.position = newPosition
            touchPosition = []
            for touch in 0..<recognizer.numberOfTouches {
                touchPosition.append(recognizer.location(ofTouch: touch, in: self))
            }
            trashView.changeStatus(touchPosition)
        case .ended:
            if trashView.contains(touchPosition) {
                movableView.remove()
            }
            trashView.hide()
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func textPinched(recognizer: UIPinchGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableTextView else { return }
        
        switch recognizer.state {
        case .began:
            originTransformations.scale = movableView.scale
        case .changed, .ended:
            let newScale = originTransformations.scale * recognizer.scale
            movableView.scale = newScale
        case .cancelled, .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// TO DO: Change to TrashView
private extension UIView {
    
    func changeStatus(_ points: [CGPoint]) {
        let fingerOnView = self.contains(points)
        
        if fingerOnView {
            open()
        }
        else {
            close()
        }
    }
    
    func open() {
        alpha = 1
        backgroundColor = .blue
    }
    
    func close() {
        alpha = 1
        backgroundColor = .red
    }
    
    func hide() {
        alpha = 0
    }
}
