//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

public extension UIColor {

    /**
     Create UIColor from the given hex value

     - parameter hex:   String value to be converted to UIColor
     - parameter alpha: Alpha of the color, defaults to 1
     */
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        if hexString.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(scanner.string.startIndex, offsetBy: 1)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /**
     Create UIColor from the given hex Integer

     - parameter hex:   Int value to be converted to UIColor
     - parameter alpha: Alpha of the color, defaults to 1
     */
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(hex: UInt32(hex), alpha: alpha)
    }

    /**
     Create UIColor from the given 32-bit unsigned integer.

     - parameter hex:   UInt32 value to be converted to UIColor
     - parameter alpha: Alpha of the color, defaults to 1
     */
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}
