//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Extension to check if a color is visible
extension UIColor {
    
    /// Whether the color is visible or not, based on its alpha component.
    var isVisible: Bool {
        return rgbaComponents.alpha > 0
    }
}
