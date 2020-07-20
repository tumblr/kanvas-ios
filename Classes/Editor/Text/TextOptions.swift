//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

private struct Constants {
    static let defaultText: String = ""
    static let defaultColor: UIColor = .white
    static let defaultHighlightColor: UIColor = .clear
    static let defaultAlignment: NSTextAlignment = .left
    static let defaultTextContainerInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)
}

final class TextOptions {
    
    let text: String
    let font: UIFont?
    let color: UIColor?
    let highlightColor: UIColor?
    let alignment: NSTextAlignment
    let textContainerInset: UIEdgeInsets
    
    /// Checks if the text inside the options has text or is empty
    var haveText: Bool {
        return !text.isEmpty
    }
    
    init(text: String = Constants.defaultText,
         font: UIFont?,
         color: UIColor? = Constants.defaultColor,
         highlightColor: UIColor? = Constants.defaultHighlightColor,
         alignment: NSTextAlignment = Constants.defaultAlignment,
         textContainerInset: UIEdgeInsets = Constants.defaultTextContainerInset) {
        
        self.text = text
        self.font = font
        self.color = color
        self.highlightColor = highlightColor
        self.alignment = alignment
        self.textContainerInset = textContainerInset
    }
}
