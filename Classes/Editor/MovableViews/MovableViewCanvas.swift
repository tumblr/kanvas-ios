//
//  MovableViewCanvas.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 27/08/2019.
//

import Foundation
import UIKit

/// Protocol for movable view canvas methods
protocol MovableViewCanvasDelegate: class {
    /// Called when a movable view is tapped
    ///
    /// - Parameter option: text style options
    /// - Parameter transformations: transformations for the view
    func didTapTextView(options: TextOptions, transformations: ViewTransformations)
    
    /// Called when text is removed
    func didRemoveText()

    /// Called when text is moved
    func didMoveText()
    
    /// Called when an image is removed
    ///
    ///  - Parameter imageView:the image view that was removed
    func didRemoveImage(_ imageView: StylableImageView)

    /// Called when an image is moved
    ///
    ///  - Parameter imageView:the image view that was moved
    func didMoveImage(_ imageView: StylableImageView)
    
    /// Called when a touch event on a movable view begins
    func didBeginTouchesOnMovableView()
    
    /// Called when the touch events on a movable view end
    func didEndTouchesOnMovableView()
}

/// Constants for the canvas
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let trashViewSize: CGFloat = 98
    static let trashViewBottomMargin: CGFloat = 93
    static let overlayColor = UIColor.black.withAlphaComponent(0.7)
}

/// View that contains the collection of movable views
final class MovableViewCanvas: IgnoreTouchesView, UIGestureRecognizerDelegate, MovableViewDelegate {
    
    weak var delegate: MovableViewCanvasDelegate?
    
    // View that has been tapped
    private var selectedMovableView: MovableView?
    
    // View being touched at the moment
    private var currentMovableView: MovableView?
    
    // Touch locations during a long press
    private var touchPosition: [CGPoint] = []
    
    // Layout
    private let overlay: UIView
    private let trashView: TrashView
    
    // Values from which the different gestures start
    private var originTransformations: ViewTransformations
    
    var isEmpty: Bool {
        return subviews.compactMap{ $0 as? MovableView }.count == 0
    }
    
    init() {
        overlay = UIView()
        trashView = TrashView()
        originTransformations = ViewTransformations()
        super.init(frame: .zero)
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setUpViews() {
        setUpOverlay()
        setUpTrashView()
    }
    
    /// Sets up the trash bin used during deletion
    private func setUpTrashView() {
        trashView.accessibilityIdentifier = "Editor Movable View Canvas Trash View"
        trashView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trashView)
        
        NSLayoutConstraint.activate([
            trashView.heightAnchor.constraint(equalToConstant: Constants.trashViewSize),
            trashView.widthAnchor.constraint(equalToConstant: Constants.trashViewSize),
            trashView.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            trashView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor, constant: -Constants.trashViewBottomMargin),
        ])
    }
    
    /// Sets up the translucent black view used during deletion
    private func setUpOverlay() {
        overlay.accessibilityIdentifier = "Editor Movable View Canvas Overlay"
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = Constants.overlayColor
        addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        overlay.alpha = 0
    }
    
    // MARK: - Public interface
    
    /// Adds a new view to the canvas
    /// - Parameters
    ///  - view: view to be added
    ///  - transformations: transformations for the view
    ///  - location: location of the view before transformations
    ///  - size: size of the view
    func addView(view: MovableViewInnerElement, transformations: ViewTransformations, location: CGPoint, size: CGSize) {
        let movableView = MovableView(view: view, transformations: transformations)
        movableView.delegate = self
        movableView.isUserInteractionEnabled = true
        movableView.isExclusiveTouch = true
        movableView.isMultipleTouchEnabled = true
        movableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(movableView)
        
        NSLayoutConstraint.activate([
            movableView.heightAnchor.constraint(equalToConstant: size.height),
            movableView.widthAnchor.constraint(equalToConstant: size.width),
            movableView.topAnchor.constraint(equalTo: topAnchor, constant: location.y - (size.height / 2)),
            movableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: location.x - (size.width / 2))
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(movableViewTapped(recognizer:)))
        let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(movableViewRotated(recognizer:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(movableViewPinched(recognizer:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(movableViewPanned(recognizer:)))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(movableViewLongPressed(recognizer:)))
        
        tapRecognizer.delegate = self
        rotationRecognizer.delegate = self
        pinchRecognizer.delegate = self
        panRecognizer.delegate = self
        longPressRecognizer.delegate = self

        movableView.addGestureRecognizer(tapRecognizer)
        movableView.addGestureRecognizer(rotationRecognizer)
        movableView.addGestureRecognizer(pinchRecognizer)
        movableView.addGestureRecognizer(panRecognizer)
        movableView.addGestureRecognizer(longPressRecognizer)
        
        UIView.animate(withDuration: Constants.animationDuration) {
            movableView.moveToDefinedPosition()
        }
    }
    
    /// Removes the tapped view from the canvas
    func removeSelectedView() {
        selectedMovableView?.removeFromSuperview()
        selectedMovableView = nil
    }
    
    // MARK: - Gesture recognizers
    
    @objc func movableViewTapped(recognizer: UITapGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }
        movableView.onTap()
    }
    
    @objc func movableViewRotated(recognizer: UIRotationGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }

        switch recognizer.state {
        case .began:
            onRecognizerBegan(view: movableView)
            originTransformations.rotation = movableView.rotation
        case .changed:
            let newRotation = originTransformations.rotation + recognizer.rotation
            movableView.rotation = newRotation
        case .ended:
            onRecognizerEnded()
            movableView.onMove()
        case .cancelled, .failed:
            onRecognizerEnded()
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func movableViewPinched(recognizer: UIPinchGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }
        
        switch recognizer.state {
        case .began:
            onRecognizerBegan(view: movableView)
            originTransformations.scale = movableView.scale
        case .changed:
            let newScale = originTransformations.scale * recognizer.scale
            movableView.scale = newScale
        case .ended:
            onRecognizerEnded()
            movableView.onMove()
        case .cancelled, .failed:
            onRecognizerEnded()
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func movableViewPanned(recognizer: UIPanGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }
        
        switch recognizer.state {
        case .began:
            onRecognizerBegan(view: movableView)
            originTransformations.position = movableView.position
        case .changed:
            let newPosition = originTransformations.position + recognizer.translation(in: self)
            movableView.position = newPosition
        case .ended:
            onRecognizerEnded()
            movableView.onMove()
        case .cancelled, .failed:
            onRecognizerEnded()
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    @objc func movableViewLongPressed(recognizer: UILongPressGestureRecognizer) {
        guard let movableView = recognizer.view as? MovableView else { return }
        
        switch recognizer.state {
        case .began:
            onRecognizerBegan(view: movableView)
            showOverlay(true)
            movableView.fadeOut()
            touchPosition = recognizer.touchLocations
            trashView.changeStatus(touchPosition)
        case .changed:
            touchPosition = recognizer.touchLocations
            trashView.changeStatus(touchPosition)
        case .ended, .cancelled, .failed:
            if trashView.contains(touchPosition) {
                movableView.remove()
            }
            else {
                movableView.fadeIn()
            }
            showOverlay(false)
            trashView.hide()
            onRecognizerEnded()
        case .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let oneIsTapGesture = gestureRecognizer is UITapGestureRecognizer || otherGestureRecognizer is UITapGestureRecognizer
        return !oneIsTapGesture
    }
    
    // MARK: - MovableViewDelegate
    
    func didTapTextView(movableView: MovableView, textView: StylableTextView) {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            movableView.goBackToOrigin()
        }, completion: { [weak self] _ in
            self?.delegate?.didTapTextView(options: textView.options, transformations: movableView.transformations)
            self?.selectedMovableView = movableView
        })
    }
    
    func didTapImageView(movableView: MovableView, imageView: StylableImageView) {
        if let frontView = subviews.last, frontView != movableView {
            bringSubviewToFront(movableView)
        }
        else if let stickerImage = imageView.image {
            imageView.image = stickerImage.withHorizontallyFlippedOrientation()
        }
    }
    
    func didMoveTextView() {
        delegate?.didMoveText()
    }
    
    func didMoveImageView(_ imageView: StylableImageView) {
        delegate?.didMoveImage(imageView)
    }
    
    func didRemoveTextView() {
        delegate?.didRemoveText()
    }
    
    func didRemoveImageView(_ imageView: StylableImageView) {
        delegate?.didRemoveImage(imageView)
    }
    
    // MARK: - Private utilities
    
    /// shows or hides the overlay
    ///
    /// - Parameter show: true to show, false to hide
    private func showOverlay(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.overlay.alpha = show ? 1 : 0
        }
    }
    
    // MARK: - Extended touch area
    
    private func onRecognizerBegan(view: MovableView) {
        if currentMovableView == nil {
            didBeginTouches(on: view)
        }
    }
    
    private func onRecognizerEnded() {
        guard let currentMovableView = currentMovableView,
            let recognizers = currentMovableView.gestureRecognizers else { return }
        
        let allRecognizersAreInactive = recognizers.allSatisfy { $0.isInactive }
        if allRecognizersAreInactive {
            didEndTouches()
        }
    }
    
    func didBeginTouches(on view: MovableView) {
        currentMovableView = view
        delegate?.didBeginTouchesOnMovableView()
    }
    
    func didEndTouches() {
        currentMovableView = nil
        delegate?.didEndTouchesOnMovableView()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let currentMovableView = currentMovableView {
            return currentMovableView
        }
        else {
            return super.hitTest(point, with: event)
        }
    }
}

// Extension for obtaining touch locations easily
private extension UILongPressGestureRecognizer {
    
    var touchLocations: [CGPoint] {
        var locations: [CGPoint] = []
        for touch in 0..<numberOfTouches {
            locations.append(location(ofTouch: touch, in: view?.superview))
        }
        
        return locations
    }
}
