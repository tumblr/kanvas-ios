//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

private struct ActionsViewConstants {
    static let buttonMargin: CGFloat = CameraConstants.buttonMargin * 3/2
    static let buttonSize: CGFloat = 50
    static let animationDuration: TimeInterval = 0.5
}

/// Protocol for handling ActionsView's interaction.
protocol ActionsViewDelegate: class {
    
}

final class ActionsView: IgnoreTouchesView {

    weak var delegate: ActionsViewDelegate?

    init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable, message: "use init() instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Layout
    
    private func setupActionButton(button: UIButton,
                                   image: UIImage?,
                                   identifier: String,
                                   action: Selector,
                                   constraints: [NSLayoutConstraint]) {
        button.accessibilityIdentifier = identifier
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: action, for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }

}
