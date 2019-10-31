//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Extension for obtaining the brightness of a color.
extension UIColor {
    
    /// The brightness ranges from 0.0 (black) to 1.0 (white).
    var brightness: Double {
        return Double(rgbaComponents.red * 299 + rgbaComponents.green * 587 + rgbaComponents.blue * 114) / 1000.0
    }
}
