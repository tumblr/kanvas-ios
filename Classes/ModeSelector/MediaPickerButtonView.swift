//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import UIKit

/// Media Picker Button Delegate
protocol MediaPickerButtonViewDelegate: AnyObject {

    /// Called when the media picker button is pressed
    func mediaPickerButtonDidPress()
}

/// Media Picker Button
final class MediaPickerButtonView: IgnoreTouchesView {

    private struct Constants {
        static let borderWidth: CGFloat = 2
        static let cornerRadius: CGFloat = 5
        static let borderColor: CGColor = UIColor.white.cgColor
        static let backgroundColor: UIColor = .white
        static let shadowColor: CGColor = UIColor.black.cgColor
        static let shadowOffset: CGSize = .zero
        static let shadowOpacity: Float = 0.5
        static let shadowRadius: CGFloat = 1
        static let glowRadius: CGFloat = 10
        static let glowOffIntensity: CGFloat = 0
        static let glowOnIntensity: CGFloat = 0.6
        static let glowAnimationDuration: TimeInterval = 0.1
        static let glowOpacity: Float = 1
        static let glowOffset: CGSize = .zero
    }

    private var buttonView = UIButton()

    private weak var glowView: UIView?

    weak var delegate: MediaPickerButtonViewDelegate?

    // MARK: Internal API

    /// Designated constructor
    /// - parameter settings: camera settings
    init(settings: CameraSettings) {
        super.init(frame: .zero)

        if settings.features.mediaPicking {
            buttonView.accessibilityLabel = "Media Picker Button"
            buttonView.layer.masksToBounds = true
            layer.shadowColor = Constants.shadowColor
            layer.shadowOffset = Constants.shadowOffset
            layer.shadowOpacity = Constants.shadowOpacity
            layer.shadowRadius = Constants.shadowRadius
            layer.masksToBounds = false
            buttonView.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
            buttonView.add(into: self)
            
            buttonView.addTarget(self, action: #selector(startGlow), for: .touchDown)
            buttonView.addTarget(self, action: #selector(stopGlow), for: .touchUpOutside)
            buttonView.addTarget(self, action: #selector(stopGlow), for: .touchCancel)
            buttonView.addTarget(self, action: #selector(stopGlow), for: .touchDragExit)
            
            if let defaultImage = KanvasImages.imageThumbnail {
                setBackgroundImage(defaultImage)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Shows or hides the button
    /// - parameter visible: Whether to make the button visible or not
    /// - parameter animated: Whether to animate the transition
    func showButton(_ visible: Bool, animated: Bool = true) {
        if visible {
            showViews(shownViews: [buttonView], hiddenViews: [], animated: animated)
        }
        else {
            showViews(shownViews: [], hiddenViews: [buttonView], animated: animated)
        }
    }

    /// Sets the thumbnail of the button
    /// - parameter image: thumbnail
    func setThumbnail(_ image: UIImage) {
        setBorderStyle()
        setBackgroundImage(image)
    }

    /// Resets the media picker button
    func reset() {
        stopGlow(animated: false)
    }

    // MARK: Private API
    
    @objc private func buttonTouchUpInside() {
        delegate?.mediaPickerButtonDidPress()
    }

    @objc private func startGlow() {
        setupGlow(color: .white, intensity: Constants.glowOffIntensity)
        UIView.animate(withDuration: Constants.glowAnimationDuration) { [weak self] in
            self?.glowView?.alpha = Constants.glowOnIntensity
        }
    }

    @objc private func stopGlow(animated: Bool) {
        if animated {
            UIView.animate(withDuration: Constants.glowAnimationDuration) { [weak self] in
                self?.glowView?.alpha = Constants.glowOffIntensity
            }
        }
        else {
            glowView?.alpha = Constants.glowOffIntensity
        }
    }

    private func setupGlow(color: UIColor, intensity: CGFloat) {
        guard self.glowView == nil else {
            return
        }

        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        self.layer.render(in: context)
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        color.setFill()
        path.fill(with: .sourceAtop, alpha: 1.0)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return
        }
        UIGraphicsEndImageContext()

        let glowView = UIImageView(image: image)
        glowView.center = self.center
        self.superview?.insertSubview(glowView, aboveSubview: self)

        glowView.alpha = intensity
        glowView.layer.shadowColor = color.cgColor
        glowView.layer.shadowOffset = Constants.glowOffset
        glowView.layer.shadowRadius = Constants.glowRadius
        glowView.layer.shadowOpacity = Constants.glowOpacity

        self.glowView = glowView
    }
    
    private func setBorderStyle() {
        buttonView.layer.borderColor = Constants.borderColor
        buttonView.layer.borderWidth = Constants.borderWidth
        buttonView.layer.cornerRadius = Constants.cornerRadius
        buttonView.backgroundColor = Constants.backgroundColor
    }
    
    private func setBackgroundImage(_ image: UIImage) {
        buttonView.setBackgroundImage(image, for: .normal)
        buttonView.setBackgroundImage(image, for: .highlighted)
        buttonView.setBackgroundImage(image, for: .selected)
    }
}
