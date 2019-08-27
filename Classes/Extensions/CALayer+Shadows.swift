//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/**
 This is an extension to apply a drop shadow to layers using the same styling
 */

// Values of the shadow properties
private struct Constants {
    static let color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
    static let offset = CGSize(width: 0.0, height: 0.0)
    static let opacity: Float = 1.0
    static let radius: CGFloat = 3.0
}

extension CALayer {
    func applyShadows() {
        shadowColor = Constants.color.cgColor
        shadowOffset = Constants.offset
        shadowOpacity = Constants.opacity
        shadowRadius = Constants.radius
        masksToBounds = false
    }
}
