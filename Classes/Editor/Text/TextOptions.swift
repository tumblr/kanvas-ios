//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct Constants {
    static let defaultText: String = ""
    static let defaultFont: UIFont = .blueberryMedium()
    static let defaultColor: UIColor = .white
}

final class TextOptions {
    
    let text: String
    let font: UIFont?
    let color: UIColor?
    
    /// Checks if the text inside the options has text or is empty
    var haveText: Bool {
        return !text.isEmpty
    }
    
    init(text: String = Constants.defaultText,
         font: UIFont? = Constants.defaultFont,
         color: UIColor? = Constants.defaultColor) {
        
        self.text = text
        self.font = font
        self.color = color
    }
}
