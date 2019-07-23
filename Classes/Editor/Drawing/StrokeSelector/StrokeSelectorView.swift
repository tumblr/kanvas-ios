//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol StrokeSelectorViewDelegate: class {
    /// Called when the stroke button is held
    ///
    /// - Parameter recognizer: the long press gesture recognizer
    func didLongPressStrokeButton(recognizer: UILongPressGestureRecognizer)
    
    /// Called when the animation for onboarding begins
    func didAnimationStart()
    
    /// Called when the animation for onboarding ends
    func didAnimationEnd()
}

private struct StrokeSelectorViewConstants {
    static let animationDuration: TimeInterval = 0.25
    
    static let verticalSelectorHeight: CGFloat = 128
    static let verticalSelectorWidth: CGFloat = 34
    
    static let strokeCircleMinSize: CGFloat = 11
    static let strokeCircleMaxSize: CGFloat = 18
    static let strokeSelectorPadding: CGFloat = 11
}

final class StrokeSelectorView: IgnoreTouchesView {
    
    static let verticalSelectorHeight: CGFloat = StrokeSelectorViewConstants.verticalSelectorHeight
    static let verticalSelectorWidth: CGFloat = StrokeSelectorViewConstants.verticalSelectorWidth
    static let strokeCircleMinSize: CGFloat = StrokeSelectorViewConstants.strokeCircleMinSize
    static let strokeCircleMaxSize: CGFloat = StrokeSelectorViewConstants.strokeCircleMaxSize
    
    weak var delegate: StrokeSelectorViewDelegate?
    
    private let strokeButton: CircularImageView
    private let strokeButtonCircle: UIImageView
    private let strokeSelectorBackground: CircularImageView
    private let strokeSelectorCircle: UIImageView
    let strokeSelectorPannableArea: UIView
    
    
    init() {
        strokeButton = CircularImageView()
        strokeButtonCircle = UIImageView()
        strokeSelectorBackground = CircularImageView()
        strokeSelectorPannableArea = UIView()
        strokeSelectorCircle = UIImageView()
        super.init(frame: .zero)
        
        clipsToBounds = false
        setUpViews()
    }
    
    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Layout
    
    private func setUpViews() {
        setUpStrokeButton()
        setUpStrokeButtonCircle()
        setUpStrokeSelectorBackground()
        setUpStrokeSelectorPannableArea()
        setUpStrokeSelectorCircle()
    }
    
    /// Sets up the stroke button on the main menu
    private func setUpStrokeButton() {
        strokeButton.accessibilityIdentifier = "Editor Stroke Button"
        strokeButton.backgroundColor = .white
        strokeButton.contentMode = .center
        addSubview(strokeButton)
        
        NSLayoutConstraint.activate([
            strokeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            strokeButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            strokeButton.heightAnchor.constraint(equalToConstant: CircularImageView.size),
            strokeButton.widthAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
        
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: #selector(strokeButtonLongPressed(recognizer:)))
        longPressRecognizer.minimumPressDuration = 0
        strokeButton.addGestureRecognizer(longPressRecognizer)
    }
    
    /// Sets up the black circle inside the stroke button
    private func setUpStrokeButtonCircle() {
        strokeButtonCircle.accessibilityIdentifier = "Editor Stroke Button Circle"
        strokeButtonCircle.image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        strokeButtonCircle.tintColor = .black
        strokeButtonCircle.isUserInteractionEnabled = true
        strokeButtonCircle.translatesAutoresizingMaskIntoConstraints = false
        strokeButtonCircle.contentMode = .scaleAspectFill
        strokeButtonCircle.clipsToBounds = true
        strokeButton.addSubview(strokeButtonCircle)
        
        NSLayoutConstraint.activate([
            strokeButtonCircle.heightAnchor.constraint(equalToConstant: StrokeSelectorViewConstants.strokeCircleMinSize),
            strokeButtonCircle.widthAnchor.constraint(equalToConstant: StrokeSelectorViewConstants.strokeCircleMinSize),
            strokeButtonCircle.centerXAnchor.constraint(equalTo: strokeButton.centerXAnchor),
            strokeButtonCircle.centerYAnchor.constraint(equalTo: strokeButton.centerYAnchor),
        ])
    }
    
    /// Sets up the rounded white background for the stroke selector
    private func setUpStrokeSelectorBackground() {
        strokeSelectorBackground.accessibilityIdentifier = "Editor Stroke Selector Background"
        strokeSelectorBackground.backgroundColor = .white
        strokeSelectorBackground.add(into: self)
        
        strokeSelectorBackground.alpha = 0
    }
    
    /// Sets up the area of the stroke selector that can be panned
    private func setUpStrokeSelectorPannableArea() {
        strokeSelectorPannableArea.accessibilityIdentifier = "Editor Stroke Selector Pannable Area"
        strokeSelectorPannableArea.translatesAutoresizingMaskIntoConstraints = false
        strokeSelectorBackground.addSubview(strokeSelectorPannableArea)
        
        NSLayoutConstraint.activate([
            strokeSelectorPannableArea.leadingAnchor.constraint(equalTo: strokeSelectorBackground.leadingAnchor),
            strokeSelectorPannableArea.trailingAnchor.constraint(equalTo: strokeSelectorBackground.trailingAnchor),
            strokeSelectorPannableArea.bottomAnchor.constraint(equalTo: strokeSelectorBackground.bottomAnchor, constant: -StrokeSelectorViewConstants.strokeSelectorPadding),
            strokeSelectorPannableArea.topAnchor.constraint(equalTo: strokeSelectorBackground.topAnchor, constant: StrokeSelectorViewConstants.strokeSelectorPadding + (StrokeSelectorViewConstants.strokeCircleMaxSize - StrokeSelectorViewConstants.strokeCircleMinSize) / 2),
        ])
    }
    
    /// Sets up the moving circle inside the stroke selector
    private func setUpStrokeSelectorCircle() {
        strokeSelectorCircle.accessibilityIdentifier = "Editor Stroke Selector Circle"
        strokeSelectorCircle.image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        strokeSelectorCircle.tintColor = .black
        strokeSelectorCircle.isUserInteractionEnabled = true
        strokeSelectorCircle.translatesAutoresizingMaskIntoConstraints = false
        strokeSelectorCircle.contentMode = .scaleAspectFill
        strokeSelectorCircle.clipsToBounds = true
        strokeSelectorPannableArea.addSubview(strokeSelectorCircle)
        
        NSLayoutConstraint.activate([
            strokeSelectorCircle.heightAnchor.constraint(equalToConstant: StrokeSelectorViewConstants.strokeCircleMinSize),
            strokeSelectorCircle.widthAnchor.constraint(equalToConstant: StrokeSelectorViewConstants.strokeCircleMinSize),
            strokeSelectorCircle.centerXAnchor.constraint(equalTo: strokeSelectorPannableArea.centerXAnchor),
            strokeSelectorCircle.bottomAnchor.constraint(equalTo: strokeSelectorPannableArea.bottomAnchor),
        ])
    }
    
    // MARK: - Gesture Recognizers
    
    @objc func strokeButtonLongPressed(recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPressStrokeButton(recognizer: recognizer)
    }
    
    // MARK: - Public interface
    
    /// shows or hides the stroke selector
    ///
    /// - Parameter show: true to show, false to hide
    func showStrokeSelectorBackground(_ show: Bool) {
        UIView.animate(withDuration: StrokeSelectorViewConstants.animationDuration) {
            self.strokeSelectorBackground.alpha = show ? 1 : 0
        }
    }
    
    /// Changes the stroke circle location inside the stroke selector
    ///
    /// - Parameter location: the new position of the circle
    func moveStrokeSelectorCircle(to location: CGPoint) {
        strokeSelectorCircle.center = location
    }
    
    /// Applies a transformation to the circles inside stroke button and stroke selector
    ///
    /// - Parameter transform: the transformation to apply
    func transformStrokeCircles(_ transform: CGAffineTransform) {
        strokeButtonCircle.transform = transform
        strokeSelectorCircle.transform = transform
    }
    
    /// Shows the stroke selector animation for onboarding
    func showStrokeSelectorAnimation() {
        
        let duration = 4.0
        let maxScale = StrokeSelectorView.strokeCircleMaxSize / StrokeSelectorView.strokeCircleMinSize
        let maxHeight = (strokeSelectorPannableArea.bounds.height + strokeSelectorCircle.bounds.height) / 2

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5 / duration, animations: {
                self.delegate?.didAnimationStart()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5 / duration, relativeDuration: 0.5 / duration, animations: {
                self.strokeSelectorBackground.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 1.0 / duration, relativeDuration: 1.0 / duration, animations: {
                var transform = CGAffineTransform(translationX: 0.0, y: -maxHeight)
                transform = transform.concatenating(CGAffineTransform(scaleX: maxScale, y: maxScale))
                self.strokeSelectorCircle.transform = transform
            })
            UIView.addKeyframe(withRelativeStartTime: 2.0 / duration, relativeDuration: 1.0 / duration, animations: {
                var transform = CGAffineTransform(translationX: 0.0, y: 0.0)
                transform = transform.concatenating(CGAffineTransform(scaleX: 1.0, y: 1.0))
                self.strokeSelectorCircle.transform = transform
            })
            UIView.addKeyframe(withRelativeStartTime: 3.0 / duration, relativeDuration: 0.5 / duration, animations: {
                self.strokeSelectorBackground.alpha = 0
            })
            UIView.addKeyframe(withRelativeStartTime: 3.5 / duration, relativeDuration: 0.5 / duration, animations: {
                self.delegate?.didAnimationEnd()
            })
        }, completion: nil)
    }
}
