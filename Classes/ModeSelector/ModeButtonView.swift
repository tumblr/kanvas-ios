//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol to handle mode button user actions
protocol ModeButtonViewDelegate: AnyObject {

    /// Function called when mode button was tapped
    func modeButtonViewDidTap()

}

private struct ModeButtonViewConstants {
    static let contentVerticalInset: CGFloat = 6
    static let contentHorizontalInset: CGFloat = 20
    static let borderWidth: CGFloat = 2
    static let buttonFont: UIFont = KanvasFonts.shared.modeButtonFont
}

/// The capsule mode button view
final class ModeButtonView: IgnoreTouchesView {

    private let modeButton: UIButton

    weak var delegate: ModeButtonViewDelegate?

    private var disposables: [NSKeyValueObservation] = []

    init() {
        modeButton = UIButton()

        super.init(frame: .zero)

        backgroundColor = .clear
        isUserInteractionEnabled = true
        setUpButton()
    }

    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets the displayed title for the button
    ///
    /// - Parameter title: The string to display
    func setTitle(_ title: String) {
        modeButton.setTitle(title, for: .normal)
    }

    private func setUpButton() {
        modeButton.backgroundColor = .clear
        modeButton.contentHorizontalAlignment = .center
        modeButton.contentEdgeInsets = UIEdgeInsets(top: ModeButtonViewConstants.contentVerticalInset,
                                                    left: ModeButtonViewConstants.contentHorizontalInset,
                                                    bottom: ModeButtonViewConstants.contentVerticalInset,
                                                    right: ModeButtonViewConstants.contentHorizontalInset)
        modeButton.setTitle("", for: .normal)   // Needed so there is a title label which we can set font to.
        modeButton.titleLabel?.font = ModeButtonViewConstants.buttonFont
        modeButton.setTitleColor(.white, for: .normal)

        modeButton.layer.borderWidth = ModeButtonViewConstants.borderWidth
        modeButton.layer.borderColor = UIColor.white.cgColor
        disposables.append(modeButton.observe(\.bounds) { object, _ in
            object.layer.cornerRadius = object.bounds.height / 2
        })

        modeButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)

        modeButton.add(into: self)
    }

    @objc private func buttonPressed() {
        delegate?.modeButtonViewDidTap()
    }

}
