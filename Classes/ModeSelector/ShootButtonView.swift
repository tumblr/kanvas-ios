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

}

private struct ShootButtonViewConstants {
    static let ImageWidth: CGFloat = 30
    static let BorderWidth: CGFloat = 3
    static let LongPressMinimumDuration: CFTimeInterval = 0.5
    static let ButtonInactiveWidth: CGFloat = (ImageWidth + 15) * 2
    static let ButtonActiveWidth: CGFloat = ButtonInactiveWidth + 10
    static let ButtonSizeAnimationDuration: TimeInterval = 0.2
    static let ButtonImageAnimationInDuration: TimeInterval = 0.5
    static let ButtonImageAnimationInSpringDamping: CGFloat = 0.6
    static let ButtonImageAnimationOutDuration: TimeInterval = 0.15

    static var ButtonMaximumWidth: CGFloat {
        return max(ButtonInactiveWidth, ButtonActiveWidth)
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
final class ShootButtonView: IgnoreTouchesView {

    weak var delegate: ShootButtonViewDelegate?

    private let containerView: UIView
    private let imageView: UIImageView
    private let tapRecognizer: UITapGestureRecognizer
    private let longPressRecognizer: UILongPressGestureRecognizer
    private let borderView: UIView
    private let baseColor: UIColor
    private let activeColor: UIColor

    private var containerWidthConstraint: NSLayoutConstraint?
    private var imageWidthConstraint: NSLayoutConstraint?
    private var trigger: CaptureTrigger

    private let timeSegmentLayer: CAShapeLayer
    private var maximumTime: TimeInterval?
    private var buttonState: ShootButtonState = .neutral
    
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
        setUpRecognizers()
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
        let widthConstaint = containerView.widthAnchor.constraint(equalToConstant: ShootButtonViewConstants.ButtonInactiveWidth)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor),
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
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: ShootButtonViewConstants.ImageWidth)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            widthConstraint,
            imageView.centerXAnchor.constraint(equalTo: safeLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: safeLayoutGuide.centerYAnchor)
        ])
        imageWidthConstraint = widthConstraint
    }

    private func setUpBorderView() {
        borderView.accessibilityIdentifier = "Camera Shoot Button Border View"
        borderView.layer.masksToBounds = true
        borderView.layer.borderWidth = ShootButtonViewConstants.BorderWidth
        borderView.layer.borderColor = baseColor.cgColor
        borderView.isUserInteractionEnabled = false

        borderView.add(into: containerView)

        borderView.layer.cornerRadius = borderView.bounds.width / 2
    }

    private func setUpRecognizers() {
        configureTapRecognizer()
        configureLongPressRecognizer()
        containerView.addGestureRecognizer(tapRecognizer)
        containerView.addGestureRecognizer(longPressRecognizer)
    }

    // MARK: - Gesture Recognizers

    private func configureTapRecognizer() {
        tapRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
    }

    private func configureLongPressRecognizer() {
        longPressRecognizer.minimumPressDuration = ShootButtonViewConstants.LongPressMinimumDuration
        longPressRecognizer.addTarget(self, action: #selector(handleLongPress(recognizer:)))
    }

    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        switch trigger {
        case .tap:
            if let timeLimit = maximumTime {
                animateCircle(for: timeLimit,
                              width: ShootButtonViewConstants.ButtonInactiveWidth,
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
        case .ended, .cancelled, .failed:
            updateForLongPress(started: false)
        default: break
        }
    }

    private func updateForLongPress(started: Bool) {
        animateSizeChange(bigger: started)
        if started {
            buttonState = .animating
            if let timeLimit = maximumTime {
                animateCircle(for: timeLimit,
                              width: ShootButtonViewConstants.ButtonActiveWidth,
                              completion: { [unowned self] in self.circleAnimationCallback() })
            }
            delegate?.shootButtonViewDidStartLongPress()
        } else {
            buttonState = .released
            terminateCircleAnimation()
            containerView.layer.removeAllAnimations()
            borderView.layer.removeAllAnimations()
            delegate?.shootButtonViewDidEndLongPress()
        }
    }

    // MARK: - Animations

    private func animateSizeChange(bigger: Bool) {
        let newWidth = bigger ? ShootButtonViewConstants.ButtonActiveWidth : ShootButtonViewConstants.ButtonInactiveWidth
        let newCornerRadius = newWidth / 2
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = containerView.bounds.width / 2
        animation.toValue = newCornerRadius
        animation.duration = ShootButtonViewConstants.ButtonSizeAnimationDuration
        containerView.layer.add(animation, forKey: "cornerRadius")
        borderView.layer.add(animation, forKey: "cornerRadius")
        UIView.animate(withDuration: ShootButtonViewConstants.ButtonSizeAnimationDuration, animations: {
            self.containerView.layer.cornerRadius = newCornerRadius
            self.borderView.layer.cornerRadius = newCornerRadius
            self.containerWidthConstraint?.constant = newWidth
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }, completion: { _ in })
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
        timeSegmentLayer.lineWidth = ShootButtonViewConstants.BorderWidth
        timeSegmentLayer.strokeStart = 0
        timeSegmentLayer.strokeEnd = 1
        timeSegmentLayer.lineCap = kCALineCapButt
        timeSegmentLayer.lineJoin = kCALineJoinBevel
        containerView.layer.addSublayer(timeSegmentLayer)

        let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animateStrokeEnd.duration = time
        animateStrokeEnd.fromValue = 0
        animateStrokeEnd.toValue = 1
        CATransaction.setCompletionBlock {
            completion()
        }
        timeSegmentLayer.add(animateStrokeEnd, forKey: .none)
        CATransaction.commit()
        timeSegmentLayer.strokeEnd = 1
    }

    private func createPathForCircle(with width: CGFloat) -> CGPath {
        let arcPath = UIBezierPath()
        activeColor.set()
        arcPath.lineWidth = ShootButtonViewConstants.BorderWidth
        arcPath.lineCapStyle = .butt
        arcPath.lineJoinStyle = .bevel
        arcPath.addArc(withCenter: containerView.bounds.center,
                       // Different from UIView's border, this isn't inner to the coordinate, but centered in it.
                       // So we need to subtract half the width to make it match the view's border.
                       radius: width / 2 - ShootButtonViewConstants.BorderWidth / 2,
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
        if let _ = self.imageView.image {
            UIView.animate(withDuration: ShootButtonViewConstants.ButtonImageAnimationOutDuration, animations: {
                self.imageWidthConstraint?.constant = 0
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }, completion: { _ in
                self.animateNewImageShowing(image)
            })
        } else {
            self.imageWidthConstraint?.constant = 0
            self.setNeedsLayout()
            self.layoutIfNeeded()
            animateNewImageShowing(image)
        }
    }

    private func animateNewImageShowing(_ image: UIImage?) {
        self.imageView.image = image
        UIView.animate(withDuration: ShootButtonViewConstants.ButtonImageAnimationInDuration,
                       delay: 0,
                       usingSpringWithDamping: ShootButtonViewConstants.ButtonImageAnimationInSpringDamping,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
                           self.imageWidthConstraint?.constant = ShootButtonViewConstants.ImageWidth
                           self.setNeedsLayout()
                           self.layoutIfNeeded()
        }, completion: { _ in
            self.isUserInteractionEnabled = true
        })
    }

}
