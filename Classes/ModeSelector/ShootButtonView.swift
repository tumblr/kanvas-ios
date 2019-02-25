//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Ways in which to trigger a camera mode capture
///
/// - tap: By tapping on the capture button
/// - hold: By holding the capture button pressed
/// - tapAndHold: By doing any of the actions the capture button will react some way
enum CaptureTrigger {
    case tap
    case hold
    case tapAndHold
}

/// Protocol to handle capture button user actions
protocol ShootButtonViewDelegate: class {

    /// Function called when capture button was tapped
    func shootButtonViewDidTap()
    /// Function called when the user started a long press on capture button
    func shootButtonViewDidStartLongPress()
    /// Function called when the user ended a long press on capture button
    func shootButtonViewDidEndLongPress()
    /// Function called when the button was triggered and reached the time limit
    func shootButtonReachedMaximumTime()
    /// Function called when the a clip was dropped on capture button
    func shootButtonDidReceiveDropInteraction()

    /// Function called when the button was panned to zoom
    ///
    /// - Parameters:
    ///   - currentPoint: location of the finger on the screen
    ///   - gesture: the long press gesture recognizer that performs the zoom action.
    func shootButtonDidZoom(currentPoint: CGPoint, gesture: UILongPressGestureRecognizer)
}

private struct ShootButtonViewConstants {
    static let imageWidth: CGFloat = 30
    static let borderWidth: CGFloat = 3
    static let longPressMinimumDuration: CFTimeInterval = 0.5
    static let buttonInactiveWidth: CGFloat = (imageWidth + 15) * 2
    static let buttonActiveWidth: CGFloat = buttonInactiveWidth + 10
    static let buttonSizeAnimationDuration: TimeInterval = 0.2
    static let buttonImageAnimationInDuration: TimeInterval = 0.5
    static let buttonImageAnimationInSpringDamping: CGFloat = 0.6
    static let buttonImageAnimationOutDuration: TimeInterval = 0.15
    static let animationDuration: TimeInterval = 0.5

    static var ButtonMaximumWidth: CGFloat {
        return max(buttonInactiveWidth, buttonActiveWidth)
    }
}

private enum ShootButtonState {
    case neutral
    case animating
    case released
}

/// View for a capture/shoot button.
/// It centers an image in a circle with border
/// and reacts to events by changing color
final class ShootButtonView: IgnoreTouchesView, UIDropInteractionDelegate {

    weak var delegate: ShootButtonViewDelegate?

    private let containerView: UIView
    private let imageView: UIImageView
    private let tapRecognizer: UITapGestureRecognizer
    private let longPressRecognizer: UILongPressGestureRecognizer
    private let borderView: UIView
    private let trashView: UIImageView
    private let baseColor: UIColor
    private let activeColor: UIColor

    private var containerWidthConstraint: NSLayoutConstraint?
    private var imageWidthConstraint: NSLayoutConstraint?
    private var trigger: CaptureTrigger

    private let timeSegmentLayer: CAShapeLayer
    private var maximumTime: TimeInterval?
    private var buttonState: ShootButtonState = .neutral
    private var startingPoint: CGPoint?

    static let buttonMaximumWidth = ShootButtonViewConstants.ButtonMaximumWidth

    /// designated initializer for the shoot button view
    ///
    /// - Parameters:
    ///   - baseColor: the color before recording
    ///   - activeColor: the color of the ring animation
    init(baseColor: UIColor, activeColor: UIColor) {
        containerView = UIView()
        imageView = UIImageView()
        borderView = UIView()
        trashView = UIImageView()
        tapRecognizer = UITapGestureRecognizer()
        longPressRecognizer = UILongPressGestureRecognizer()
        timeSegmentLayer = CAShapeLayer()

        self.baseColor = baseColor
        self.activeColor = activeColor
        trigger = .tap

        super.init(frame: .zero)

        backgroundColor = .clear
        isUserInteractionEnabled = true

        setUpContainerView()
        setUpImageView(imageView)
        setUpBorderView()
        setUpTrashView()
        setUpRecognizers()
        setUpInteractions()
    }

    @available(*, unavailable, message: "use init(baseColor:, pressedColor:, timeLimit:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(baseColor:, pressedColor:, timeLimit:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// The main function to set the current record type and current image
    ///
    /// - Parameters:
    ///   - trigger: The type of trigger for the button (tap, hold)
    ///   - image: the image to display in the button
    ///   - timeLimit: the animation duration of the ring
    func configureFor(trigger: CaptureTrigger, image: UIImage?, timeLimit: TimeInterval?) {
        self.trigger = trigger
        maximumTime = timeLimit
        animateImageChange(image)
    }

    // MARK: - Layout

    // Needed for corner radius being correctly set when view is shown for the first time.
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = containerView.bounds.width / 2
        borderView.layer.cornerRadius = containerView.bounds.width / 2
    }

    private func setUpContainerView() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstaint = containerView.widthAnchor.constraint(equalToConstant: ShootButtonViewConstants.buttonInactiveWidth)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor),
            widthConstaint
        ])
        containerWidthConstraint = widthConstaint
    }

    private func setUpImageView(_ imageView: UIImageView) {
        imageView.accessibilityIdentifier = "Camera Shoot Button ImageView"
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: ShootButtonViewConstants.imageWidth)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            widthConstraint,
            imageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
        ])
        imageWidthConstraint = widthConstraint
    }

    private func setUpBorderView() {
        borderView.accessibilityIdentifier = "Camera Shoot Button Border View"
        borderView.layer.masksToBounds = true
        borderView.layer.borderWidth = ShootButtonViewConstants.borderWidth
        borderView.layer.borderColor = baseColor.cgColor
        borderView.isUserInteractionEnabled = false

        borderView.add(into: containerView)

        borderView.layer.cornerRadius = borderView.bounds.width / 2
    }
    
    private func setUpTrashView() {
        trashView.add(into: containerView)
        trashView.translatesAutoresizingMaskIntoConstraints = false
        trashView.image = KanvasCameraImages.deleteImage
        showTrashView(false)
    }

    private func setUpRecognizers() {
        configureTapRecognizer()
        configureLongPressRecognizer()
        containerView.addGestureRecognizer(tapRecognizer)
        containerView.addGestureRecognizer(longPressRecognizer)
    }
    
    private func setUpInteractions() {
        containerView.addInteraction(UIDropInteraction(delegate: self))
    }
    
    // MARK: - Gesture Recognizers

    private func configureTapRecognizer() {
        tapRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
    }

    private func configureLongPressRecognizer() {
        longPressRecognizer.minimumPressDuration = ShootButtonViewConstants.longPressMinimumDuration
        longPressRecognizer.addTarget(self, action: #selector(handleLongPress(recognizer:)))
    }

    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        switch trigger {
        case .tap:
            if let timeLimit = maximumTime {
                animateCircle(for: timeLimit,
                              width: ShootButtonViewConstants.buttonInactiveWidth,
                              completion: { [unowned self] in self.circleAnimationCallback() })
            }
        case .tapAndHold:
            borderView.layer.borderColor = activeColor.cgColor
            performUIUpdateAfter(deadline: .now() + 0.1) { [unowned self] in
                self.borderView.layer.borderColor = self.baseColor.cgColor
            }
        case .hold: return // Do nothing on tap
        }
        delegate?.shootButtonViewDidTap()
    }

    @objc private func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        guard trigger == .hold || trigger == .tapAndHold else { return }
        switch recognizer.state {
        case .began:
            updateForLongPress(started: true)
            updateZoom(recognizer: recognizer)
        case .ended, .cancelled, .failed:
            updateForLongPress(started: false)
        default:
            updateZoom(recognizer: recognizer)
        }
    }

    private func updateZoom(recognizer: UILongPressGestureRecognizer) {
        let currentPoint = recognizer.location(in: containerView)
        delegate?.shootButtonDidZoom(currentPoint: currentPoint, gesture: recognizer)
    }

    private func updateForLongPress(started: Bool) {
        animateSizeChange(bigger: started)
        if started {
            buttonState = .animating
            if let timeLimit = maximumTime {
                animateCircle(for: timeLimit,
                              width: ShootButtonViewConstants.buttonActiveWidth,
                              completion: { [unowned self] in self.circleAnimationCallback() })
            }
            delegate?.shootButtonViewDidStartLongPress()
        }
        else {
            buttonState = .released
            terminateCircleAnimation()
            containerView.layer.removeAllAnimations()
            borderView.layer.removeAllAnimations()
            delegate?.shootButtonViewDidEndLongPress()
        }
    }

    // MARK: - Animations

    private func animateSizeChange(bigger: Bool) {
        let newWidth = bigger ? ShootButtonViewConstants.buttonActiveWidth : ShootButtonViewConstants.buttonInactiveWidth
        let newCornerRadius = newWidth / 2
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fromValue = containerView.bounds.width / 2
        animation.toValue = newCornerRadius
        animation.duration = ShootButtonViewConstants.buttonSizeAnimationDuration
        containerView.layer.add(animation, forKey: "cornerRadius")
        borderView.layer.add(animation, forKey: "cornerRadius")
        UIView.animate(withDuration: ShootButtonViewConstants.buttonSizeAnimationDuration) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.containerView.layer.cornerRadius = newCornerRadius
            strongSelf.borderView.layer.cornerRadius = newCornerRadius
            strongSelf.containerWidthConstraint?.constant = newWidth
            strongSelf.setNeedsLayout()
            strongSelf.layoutIfNeeded()
        }
    }

    private func circleAnimationCallback() {
        terminateCircleAnimation()
        switch buttonState {
            case .animating:
                delegate?.shootButtonReachedMaximumTime()
            default: break
        }
        buttonState = .neutral
    }

    private func animateCircle(for time: TimeInterval, width: CGFloat, completion: @escaping () -> ()) {
        timeSegmentLayer.path = createPathForCircle(with: width)
        timeSegmentLayer.strokeColor = activeColor.cgColor
        timeSegmentLayer.fillColor = UIColor.clear.cgColor
        timeSegmentLayer.lineWidth = ShootButtonViewConstants.borderWidth
        timeSegmentLayer.strokeStart = 0
        timeSegmentLayer.strokeEnd = 1
        timeSegmentLayer.lineCap = CAShapeLayerLineCap.butt
        timeSegmentLayer.lineJoin = CAShapeLayerLineJoin.bevel
        containerView.layer.addSublayer(timeSegmentLayer)

        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = time
        animateStrokeEnd.fromValue = 0
        animateStrokeEnd.toValue = 1
        CATransaction.setCompletionBlock(completion)
        timeSegmentLayer.add(animateStrokeEnd, forKey: .none)
        CATransaction.commit()
        timeSegmentLayer.strokeEnd = 1
    }

    private func createPathForCircle(with width: CGFloat) -> CGPath {
        let arcPath = UIBezierPath()
        activeColor.set()
        arcPath.lineWidth = ShootButtonViewConstants.borderWidth
        arcPath.lineCapStyle = .butt
        arcPath.lineJoinStyle = .bevel
        arcPath.addArc(withCenter: containerView.bounds.center,
                       // Different from UIView's border, this isn't inner to the coordinate, but centered in it.
                       // So we need to subtract half the width to make it match the view's border.
                       radius: width / 2 - ShootButtonViewConstants.borderWidth / 2,
                       startAngle: -.pi / 2,
                       endAngle: 3/2 * .pi,
                       clockwise: true)
        return arcPath.cgPath
    }

    private func terminateCircleAnimation() {
        timeSegmentLayer.removeAllAnimations()
        timeSegmentLayer.removeFromSuperlayer()
    }

    private func animateImageChange(_ image: UIImage?) {
        isUserInteractionEnabled = false
        if self.imageView.image != nil {
            UIView.animate(withDuration: ShootButtonViewConstants.buttonImageAnimationOutDuration, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.imageWidthConstraint?.constant = 0
                strongSelf.setNeedsLayout()
                strongSelf.layoutIfNeeded()
            }, completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.animateNewImageShowing(image)
            })
        }
        else {
            self.imageWidthConstraint?.constant = 0
            self.setNeedsLayout()
            self.layoutIfNeeded()
            animateNewImageShowing(image)
        }
    }

    private func animateNewImageShowing(_ image: UIImage?) {
        self.imageView.image = image
        UIView.animate(withDuration: ShootButtonViewConstants.buttonImageAnimationInDuration,
                       delay: 0,
                       usingSpringWithDamping: ShootButtonViewConstants.buttonImageAnimationInSpringDamping,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
                           self.imageWidthConstraint?.constant = ShootButtonViewConstants.imageWidth
                           self.setNeedsLayout()
                           self.layoutIfNeeded()
        }, completion: { _ in
            self.isUserInteractionEnabled = true
        })
    }
    
    /// Updates UI for the next button
    ///
    /// - Parameter enabled: whether to enable the next button or not
    func showTrashView(_ show: Bool) {
        UIView.animate(withDuration: ShootButtonViewConstants.animationDuration) {
            self.trashView.alpha = show ? 1 : 0
        }
    }
    
    // MARK: - UIDropInteractionDelegate
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        delegate?.shootButtonDidReceiveDropInteraction()
    }
}
