//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

// Values of the shadow properties
private struct Constants {
    static let color = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
    static let offset = CGSize(width: 0.0, height: 0.0)
    static let opacity: Float = 1.0
    static let radius: CGFloat = 3.0
}

/// Extension that applies a shadow to a layer
extension CALayer {
    
    /// Adds a shadow to the layer
    ///
    /// - Parameter color: Shadow color. The default value is black with an alpha of 0.25.
    /// - Parameter offset: Distance of the shadow from the main view. The default value is (0.0, 0.0)
    /// - Parameter opacity: Shadow opacity. The value must be in the range 0.0 (transparent) to 1.0 (opaque). The default value is 1.0.
    /// - Parameter radius: Shadow radius. The default value is 3.0.
    func applyShadows(color: UIColor = Constants.color,
                      offset: CGSize = Constants.offset,
                      opacity: Float = Constants.opacity,
                      radius: CGFloat = Constants.radius) {
        shadowColor = color.cgColor
        shadowOffset = offset
        shadowOpacity = opacity
        shadowRadius = radius
        masksToBounds = false
    }
}
