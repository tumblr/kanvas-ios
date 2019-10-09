//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Extension for adding more fonts
extension UIFont {
    
    static func fairwater(fontSize: CGFloat) -> UIFont {
        let font = UIFont(name: "Fairwater Script", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .medium)
        if UIFont.isDynamicTypeEnabled {
            return UIFontMetrics.default.scaledFont(for: font)
        }
        return font
    }
}
