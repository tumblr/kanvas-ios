//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

extension UITextView {
    
    var options: TextOptions {
        get {
            return TextOptions(text: text,
                               font: font,
                               color: textColor)
        }
        set {
            text = newValue.text
            font = newValue.font
            textColor = newValue.color
        }
    }
}
