//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct OptionConstants {
    static let inset: CGFloat = -10
}

/// A button view that handles image layout
final class OptionView: UIButton {

    init(image: UIImage?) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFit
        setImage(image, for: .normal)
        applyShadows()
    }

    @available(*, unavailable, message: "use init(image:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(image:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = bounds
        let inset = OptionConstants.inset
        let hitTestEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
}
