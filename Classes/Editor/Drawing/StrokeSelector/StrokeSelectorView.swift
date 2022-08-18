//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol StrokeSelectorViewDelegate: AnyObject {
    /// Called when the main button is held
    ///
    /// - Parameter recognizer: the long press gesture recognizer
    func didLongPressStrokeButton(recognizer: UILongPressGestureRecognizer)
    
    /// Called when the animation for onboarding begins
    func didAnimationStart()
    
    /// Called when the animation for onboarding ends
    func didAnimationEnd()
}

private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    
    static let selectorHeight: CGFloat = 128
    static let selectorWidth: CGFloat = 34
    
    static let circleMinSize: CGFloat = 11
    static let circleMaxSize: CGFloat = 18
    static let selectorPadding: CGFloat = 11
    static let selectorBottomPadding: CGFloat = selectorPadding
    static let selectorTopPadding: CGFloat = selectorPadding + (circleMaxSize - circleMinSize) / 2
    static let selectorPannableAreaHeight: CGFloat = selectorHeight - selectorTopPadding - selectorBottomPadding
    
    static let circleDefaultColor: UIColor = KanvasColors.shared.strokeColor
}

/// View for StrokeSelectorController
final class StrokeSelectorView: IgnoreTouchesView {
    
    static let selectorHeight: CGFloat = Constants.selectorHeight
    static let selectorWidth: CGFloat = Constants.selectorWidth
    static let circleMinSize: CGFloat = Constants.circleMinSize
    static let circleMaxSize: CGFloat = Constants.circleMaxSize
    static let selectorPannableAreaHeight: CGFloat = Constants.selectorPannableAreaHeight
    
    weak var delegate: StrokeSelectorViewDelegate?
    
    private let mainButton: CircularImageView
    private let mainButtonCircle: UIImageView
    private let selectorBackground: SliderView
    private let selectorCircle: UIImageView
    let selectorPannableArea: UIView
    
    
    init() {
        mainButton = CircularImageView()
        mainButtonCircle = UIImageView()
        selectorBackground = SliderView()
        selectorPannableArea = UIView()
        selectorCircle = UIImageView()
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
        setUpSelectorBackground()
        setUpSelectorPannableArea()
        setUpSelectorCircle()
        setUpMainButton()
        setUpMainButtonCircle()
    }
    
    /// Sets up the button that opens the selector
    private func setUpMainButton() {
        mainButton.accessibilityIdentifier = "Stroke Main Button"
        mainButton.backgroundColor = .white
        mainButton.contentMode = .center
        addSubview(mainButton)
        
        NSLayoutConstraint.activate([
            mainButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainButton.heightAnchor.constraint(equalToConstant: CircularImageView.size),
            mainButton.widthAnchor.constraint(equalToConstant: CircularImageView.size),
        ])
        
        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: #selector(strokeButtonLongPressed(recognizer:)))
        longPressRecognizer.minimumPressDuration = 0
        mainButton.addGestureRecognizer(longPressRecognizer)
    }
    
    /// Sets up the black circle inside the main button
    private func setUpMainButtonCircle() {
        mainButtonCircle.accessibilityIdentifier = "Stroke Main Button Circle"
        mainButtonCircle.image = KanvasImages.circleImage?.withRenderingMode(.alwaysTemplate)
        mainButtonCircle.tintColor = Constants.circleDefaultColor
        mainButtonCircle.isUserInteractionEnabled = true
        mainButtonCircle.translatesAutoresizingMaskIntoConstraints = false
        mainButtonCircle.contentMode = .scaleAspectFill
        mainButtonCircle.clipsToBounds = true
        mainButton.addSubview(mainButtonCircle)
        
        NSLayoutConstraint.activate([
            mainButtonCircle.heightAnchor.constraint(equalToConstant: Constants.circleMinSize),
            mainButtonCircle.widthAnchor.constraint(equalToConstant: Constants.circleMinSize),
            mainButtonCircle.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor),
            mainButtonCircle.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor),
        ])
    }
    
    /// Sets up the rounded white background for the selector
    private func setUpSelectorBackground() {
        selectorBackground.accessibilityIdentifier = "Stroke Selector Background"
        selectorBackground.add(into: self)
        
        selectorBackground.alpha = 0
    }
    
    /// Sets up the area of the selector that can be panned
    private func setUpSelectorPannableArea() {
        selectorPannableArea.accessibilityIdentifier = "Stroke Selector Pannable Area"
        selectorPannableArea.translatesAutoresizingMaskIntoConstraints = false
        selectorBackground.addSubview(selectorPannableArea)
        
        NSLayoutConstraint.activate([
            selectorPannableArea.leadingAnchor.constraint(equalTo: selectorBackground.leadingAnchor),
            selectorPannableArea.trailingAnchor.constraint(equalTo: selectorBackground.trailingAnchor),
            selectorPannableArea.bottomAnchor.constraint(equalTo: selectorBackground.bottomAnchor, constant: -Constants.selectorBottomPadding),
            selectorPannableArea.topAnchor.constraint(equalTo: selectorBackground.topAnchor, constant: Constants.selectorTopPadding),
        ])
    }
    
    /// Sets up the movable circle inside the selector
    private func setUpSelectorCircle() {
        selectorCircle.accessibilityIdentifier = "Stroke Selector Circle"
        selectorCircle.image = KanvasImages.circleImage?.withRenderingMode(.alwaysTemplate)
        selectorCircle.tintColor = Constants.circleDefaultColor
        selectorCircle.isUserInteractionEnabled = true
        selectorCircle.translatesAutoresizingMaskIntoConstraints = false
        selectorCircle.contentMode = .scaleAspectFill
        selectorCircle.clipsToBounds = true
        selectorPannableArea.addSubview(selectorCircle)
        
        NSLayoutConstraint.activate([
            selectorCircle.heightAnchor.constraint(equalToConstant: Constants.circleMinSize),
            selectorCircle.widthAnchor.constraint(equalToConstant: Constants.circleMinSize),
            selectorCircle.centerXAnchor.constraint(equalTo: selectorPannableArea.centerXAnchor),
            selectorCircle.bottomAnchor.constraint(equalTo: selectorPannableArea.bottomAnchor),
        ])
    }
    
    // MARK: - Gesture Recognizers
    
    @objc func strokeButtonLongPressed(recognizer: UILongPressGestureRecognizer) {
        delegate?.didLongPressStrokeButton(recognizer: recognizer)
    }
    
    // MARK: - Public interface
    
    /// shows or hides the selector
    ///
    /// - Parameter show: true to show, false to hide
    func showSelectorBackground(_ show: Bool) {
        let circleInitialPosition = convert(mainButton.center, to: selectorPannableArea)
        
        if show {
            selectorBackground.alpha = 1
            selectorCircle.center = circleInitialPosition
            mainButton.alpha = 0
            selectorCircle.alpha = 1
            
            selectorBackground.open()
        }
        else {
            selectorBackground.close(animation: {
                self.selectorCircle.center = circleInitialPosition
            }, completion: {
                self.selectorBackground.alpha = 0
                self.selectorCircle.alpha = 0
                self.mainButton.alpha = 1
            })
        }
    }
    
    /// Changes the circle location inside the selector
    ///
    /// - Parameter location: the new position of the circle
    func moveSelectorCircle(to location: CGPoint) {
        selectorCircle.center = location
    }
    
    /// Applies a transformation to the circles inside main button and selector
    ///
    /// - Parameter transform: the transformation to apply
    func transformCircle(_ transform: CGAffineTransform) {
        mainButtonCircle.transform = transform
        selectorCircle.transform = transform
    }
    
    /// Changes the color of the circle inside the main button and the selector
    ///
    /// - Parameter color: the color to be applied
    func tintStrokeCircle(color: UIColor) {
        mainButtonCircle.tintColor = color
        selectorCircle.tintColor = color
    }
    
    /// Shows the animation for onboarding
    func showAnimation() {
        
        let duration = 3.5
        let maxScale = StrokeSelectorView.circleMaxSize / StrokeSelectorView.circleMinSize
        let maxHeight = (selectorPannableArea.bounds.height + selectorCircle.bounds.height) / 2
        
        selectorBackground.alpha = 1
        mainButton.alpha = 0
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5 / duration, animations: {
                self.delegate?.didAnimationStart()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5 / duration, relativeDuration: 0.5 / duration, animations: {
                self.selectorBackground.open(animated: false)
            })
            UIView.addKeyframe(withRelativeStartTime: 1.0 / duration, relativeDuration: 1.0 / duration, animations: {
                var transform = CGAffineTransform(translationX: 0.0, y: -maxHeight)
                transform = transform.concatenating(CGAffineTransform(scaleX: maxScale, y: maxScale))
                self.selectorCircle.transform = transform
            })
            UIView.addKeyframe(withRelativeStartTime: 2.0 / duration, relativeDuration: 1.0 / duration, animations: {
                var transform = CGAffineTransform(translationX: 0.0, y: 0.0)
                transform = transform.concatenating(CGAffineTransform(scaleX: 1.0, y: 1.0))
                self.selectorCircle.transform = transform
            })
            UIView.addKeyframe(withRelativeStartTime: 3.0 / duration, relativeDuration: 0.5 / duration, animations: {
                self.selectorBackground.close(animated: false)
            })
        }, completion: { _ in
            self.selectorBackground.alpha = 0
            self.mainButton.alpha = 1
            self.delegate?.didAnimationEnd()
        })
    }
}
