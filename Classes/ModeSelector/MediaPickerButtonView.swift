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

    override init(frame: CGRect) {
        super.init(frame: frame)

        let buttonView = UIButton(type: .roundedRect)
        buttonView.accessibilityLabel = "Media Picker Button"
        buttonView.backgroundColor = .white
        buttonView.applyShadows()
        buttonView.addTarget(self, action: #selector(buttonTouchUpInside), for: .touchUpInside)
        buttonView.add(into: self)
        self.buttonView = buttonView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func buttonTouchUpInside() {
        delegate?.mediaPickerButtonDidPress()
    }

}
