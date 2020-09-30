//
//  UIColor+Lerp.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 11/02/2019.
//

import Foundation

/// Extension for linear interpolation (lerp) and creation of RGBA components
extension UIColor {
    
    /// Creates an RGBA from this color
    var rgbaComponents: RGBA {
        return RGBA(color: self)
    }
    
    /// Creates a new color by linearly interpolating two other colors
    ///
    /// - Parameter from: first color
    /// - Parameter to: second color
    /// - Parameter percent: represents the percentage of the second color in the final color.
    ///             '0' results in the first color, '1' results in the second color,
    ///             and '0.5' is the color half way in between them.
    /// - Returns: the new color
    class func lerp(from: RGBA, to: RGBA, percent: CGFloat) -> UIColor {
        let red = from.red + percent * (to.red - from.red)
        let green = from.green + percent * (to.green - from.green)
        let blue = from.blue + percent * (to.blue - from.blue)
        let alpha = from.alpha + percent * (to.alpha - from.alpha)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
