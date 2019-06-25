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

class MediaPickerButtonView: UIView {

    private weak var buttonView: UIButton?

    weak var delegate: MediaPickerButtonViewDelegate?

    init(settings: CameraSettings) {
        super.init(frame: .zero)

        if settings.features.mediaPicking {
            let buttonView = UIButton(type: .roundedRect)
            buttonView.accessibilityLabel = "Media Picker Button"
            buttonView.backgroundColor = .white
            buttonView.layer.borderColor = UIColor.white.cgColor
            buttonView.layer.borderWidth = 2
            buttonView.layer.cornerRadius = 7
            buttonView.layer.masksToBounds = true
            buttonView.clipsToBounds = true
            buttonView.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
            buttonView.add(into: self)
            self.buttonView = buttonView
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showButton(_ visible: Bool) {
        buttonView?.alpha = visible ? 1 : 0
    }

    func setThumbnail(_ image: UIImage) {
        buttonView?.setBackgroundImage(image, for: .normal)
    }

    @objc func buttonTouchUpInside() {
        delegate?.mediaPickerButtonDidPress()
    }

}
