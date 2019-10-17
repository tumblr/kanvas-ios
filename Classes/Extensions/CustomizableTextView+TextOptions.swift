//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

extension CustomizableTextView {
    
    var options: TextOptions {
        get {
            return TextOptions(text: text,
                               font: font,
                               color: textColor,
                               highlightColor: highlightColor,
                               alignment: textAlignment,
                               textContainerInset: textContainerInset)
        }
        set {
            text = newValue.text
            font = newValue.font
            textColor = newValue.color
            highlightColor = newValue.highlightColor
            textAlignment = newValue.alignment
            textContainerInset = newValue.textContainerInset
        }
    }
}
