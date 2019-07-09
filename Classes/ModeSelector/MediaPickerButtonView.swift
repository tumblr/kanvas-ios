//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import UIKit

protocol MediaPickerButtonViewDelegate: class {
    func mediaPickerButtonDidPress()
}

final class MediaPickerButtonView: UIView {

    private struct Constants {
        static let borderWidth: CGFloat = 2
        static let cornerRadius: CGFloat = 5
        static let borderColor: CGColor = UIColor.white.cgColor
        static let backgroundColor: UIColor = .white
        static let shadowColor: CGColor = UIColor.black.cgColor
        static let shadowOffset: CGSize = CGSize(width: 0, height: 0)
        static let shadowOpacity: Float = 0.5
        static let shadowRadius: CGFloat = 1
    }

    private var buttonView = UIButton()

    private weak var glowView: UIView?

    weak var delegate: MediaPickerButtonViewDelegate?

    init(settings: CameraSettings) {
        super.init(frame: .zero)

        if settings.features.mediaPicking {
            buttonView.accessibilityLabel = "Media Picker Button"
            buttonView.backgroundColor = Constants.backgroundColor
            buttonView.layer.borderColor = Constants.borderColor
            buttonView.layer.borderWidth = Constants.borderWidth
            buttonView.layer.cornerRadius = Constants.cornerRadius
            buttonView.layer.masksToBounds = true
            layer.shadowColor = Constants.shadowColor
            layer.shadowOffset = Constants.shadowOffset
            layer.shadowOpacity = Constants.shadowOpacity
            layer.shadowRadius = Constants.shadowRadius
            layer.masksToBounds = false
            buttonView.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
            buttonView.add(into: self)
            buttonView.addTarget(self, action: #selector(startGlow), for: .touchDown)
            buttonView.addTarget(self, action: #selector(stopGlow), for: .touchCancel)
            buttonView.addTarget(self, action: #selector(stopGlow), for: .touchUpOutside)
            buttonView.addTarget(self, action: #selector(stopGlow), for: .touchDragExit)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showButton(_ visible: Bool) {
        if visible {
            showViews(shownViews: [buttonView], hiddenViews: [], animated: true)
        }
        else {
            showViews(shownViews: [], hiddenViews: [buttonView], animated: true)
        }
    }

    func setThumbnail(_ image: UIImage) {
        buttonView.setBackgroundImage(image, for: .normal)
        buttonView.setBackgroundImage(image, for: .highlighted)
        buttonView.setBackgroundImage(image, for: .selected)
    }

    @objc private func buttonTouchUpInside() {
        delegate?.mediaPickerButtonDidPress()
    }

    @objc private func startGlow() {
        addGlow()
    }

    @objc private func stopGlow() {
        removeGlow()
    }

    private func addGlow(color: UIColor = .white, intensity: CGFloat = 0.6) {
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
        glowView.layer.shadowOffset = CGSize.zero
        glowView.layer.shadowRadius = 10
        glowView.layer.shadowOpacity = 1.0

        self.glowView = glowView
    }

    func removeGlow() {
        self.glowView?.removeFromSuperview()
        self.glowView = nil
    }
}
