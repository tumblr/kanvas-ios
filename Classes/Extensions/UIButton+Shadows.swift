//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/**
 This is an extension to apply a drop shadow to buttons using the same styling
 */

// values of the shadow properties
private struct ButtonShadowConstants {
    static let color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
    static let offset = CGSize(width: 0.0, height: 2.0)
    static let opacity: Float = 1.0
    static let radius: CGFloat = 0.0
}

extension UIButton {
    func applyShadows() {
        layer.shadowColor = ButtonShadowConstants.color.cgColor
        layer.shadowOffset = ButtonShadowConstants.offset
        layer.shadowOpacity = ButtonShadowConstants.opacity
        layer.shadowRadius = ButtonShadowConstants.radius
        layer.masksToBounds = false
    }
}
