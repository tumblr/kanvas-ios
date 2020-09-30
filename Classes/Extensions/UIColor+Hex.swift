//
//  UIColor+Hex.swift
//  Utils
//
//  Created by Josh Smith on 3/4/19.
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
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
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

    /**
     Create UIColor from the given hex Integer

     - parameter hex:   Int value to be converted to UIColor
     - note: Method is used to bridge objc without a large multi file rewrite
     */
    @objc(colorWithHex:)
    static func color(hex: UInt) -> UIColor {
        return UIColor(hex: UInt32(hex))
    }

}
