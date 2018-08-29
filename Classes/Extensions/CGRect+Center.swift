//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

extension CGRect {

    /// convenience method for setting and getting the center
    var center: CGPoint {
        get {
            return CGPoint(x: midX,
                           y: midY)
        }
        set {
            origin.x = newValue.x - (width / 2)
            origin.y = newValue.y - (height / 2)
        }
    }

}
