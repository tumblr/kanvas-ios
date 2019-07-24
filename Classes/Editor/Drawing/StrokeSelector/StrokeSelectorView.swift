//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol StrokeSelectorViewDelegate: class {
    /// Called when the main button is held
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
    
    static let selectorHeight: CGFloat = 128
    static let selectorWidth: CGFloat = 34
    
    static let selectorPadding: CGFloat = 11
    static let strokeCircleMinSize: CGFloat = 11
    static let strokeCircleMaxSize: CGFloat = 18
}

final class StrokeSelectorView: IgnoreTouchesView {
    
    static let selectorHeight: CGFloat = StrokeSelectorViewConstants.selectorHeight
    static let selectorWidth: CGFloat = StrokeSelectorViewConstants.selectorWidth
    static let strokeCircleMinSize: CGFloat = StrokeSelectorViewConstants.strokeCircleMinSize
    static let strokeCircleMaxSize: CGFloat = StrokeSelectorViewConstants.strokeCircleMaxSize
    
    weak var delegate: StrokeSelectorViewDelegate?
    
    private let mainButton: CircularImageView
    private let mainButtonCircle: UIImageView
    private let selectorBackground: CircularImageView
    private let selectorCircle: UIImageView
    let selectorPannableArea: UIView
    
    
    init() {
        mainButton = CircularImageView()
        mainButtonCircle = UIImageView()
        selectorBackground = CircularImageView()
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
        setUpMainButton()
        setUpMainButtonCircle()
        setUpSelectorBackground()
        setUpSelectorPannableArea()
        setUpSelectorCircle()
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
        mainButtonCircle.image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        mainButtonCircle.tintColor = .black
        mainButtonCircle.isUserInteractionEnabled = true
        mainButtonCircle.translatesAutoresizingMaskIntoConstraints = false
        mainButtonCircle.contentMode = .scaleAspectFill
        mainButtonCircle.clipsToBounds = true
        mainButton.addSubview(mainButtonCircle)
        
        NSLayoutConstraint.activate([
            mainButtonCircle.heightAnchor.constraint(equalToConstant: StrokeSelectorViewConstants.strokeCircleMinSize),
            mainButtonCircle.widthAnchor.constraint(equalToConstant: StrokeSelectorViewConstants.strokeCircleMinSize),
            mainButtonCircle.centerXAnchor.constraint(equalTo: mainButton.centerXAnchor),
            mainButtonCircle.centerYAnchor.constraint(equalTo: mainButton.centerYAnchor),
        ])
    }
    
    /// Sets up the rounded white background for the selector
    private func setUpSelectorBackground() {
        selectorBackground.accessibilityIdentifier = "Stroke Selector Background"
        selectorBackground.backgroundColor = .white
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
            selectorPannableArea.bottomAnchor.constraint(equalTo: selectorBackground.bottomAnchor, constant: -StrokeSelectorViewConstants.selectorPadding),
            selectorPannableArea.topAnchor.constraint(equalTo: selectorBackground.topAnchor, constant: StrokeSelectorViewConstants.selectorPadding + (StrokeSelectorViewConstants.strokeCircleMaxSize - StrokeSelectorViewConstants.strokeCircleMinSize) / 2),
        ])
    }
    
    /// Sets up the movable circle inside the selector
    private func setUpSelectorCircle() {
        selectorCircle.accessibilityIdentifier = "Stroke Selector Circle"
        selectorCircle.image = KanvasCameraImages.circleImage?.withRenderingMode(.alwaysTemplate)
        selectorCircle.tintColor = .black
        selectorCircle.isUserInteractionEnabled = true
        selectorCircle.translatesAutoresizingMaskIntoConstraints = false
        selectorCircle.contentMode = .scaleAspectFill
        selectorCircle.clipsToBounds = true
        selectorPannableArea.addSubview(selectorCircle)
        
        NSLayoutConstraint.activate([
            selectorCircle.heightAnchor.constraint(equalToConstant: StrokeSelectorViewConstants.strokeCircleMinSize),
            selectorCircle.widthAnchor.constraint(equalToConstant: StrokeSelectorViewConstants.strokeCircleMinSize),
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
        UIView.animate(withDuration: StrokeSelectorViewConstants.animationDuration) {
            self.selectorBackground.alpha = show ? 1 : 0
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
    func transformStrokeCircle(_ transform: CGAffineTransform) {
        mainButtonCircle.transform = transform
        selectorCircle.transform = transform
    }
    
    /// Shows the animation for onboarding
    func showAnimation() {
        
        let duration = 3.5
        let maxScale = StrokeSelectorView.strokeCircleMaxSize / StrokeSelectorView.strokeCircleMinSize
        let maxHeight = (selectorPannableArea.bounds.height + selectorCircle.bounds.height) / 2
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5 / duration, animations: {
                self.delegate?.didAnimationStart()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5 / duration, relativeDuration: 0.5 / duration, animations: {
                self.selectorBackground.alpha = 1
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
                self.selectorBackground.alpha = 0
            })
        }, completion: { _ in
            self.delegate?.didAnimationEnd()
        })
    }
}
