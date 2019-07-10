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
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 5
        static let borderColor: CGColor = UIColor.white.cgColor
        static let backgroundColor: UIColor = .white
    }

    private var buttonView = UIButton(type: .roundedRect)

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
            buttonView.clipsToBounds = true
            buttonView.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
            buttonView.add(into: self)
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
    }

    @objc func buttonTouchUpInside() {
        delegate?.mediaPickerButtonDidPress()
    }

}
