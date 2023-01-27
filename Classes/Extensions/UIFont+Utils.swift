//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Extension for simplifying resizing fonts
extension UIFont {

    func withSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(descriptor: self.fontDescriptor, size: fontSize)
    }

}
