//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

extension UIColor {
    func isVisible() -> Bool {
        return rgbaComponents.alpha > 0
    }
    
    /**
    Best matching color between black and white, based on the brightness of the current color.
    
    - return: Black or white, depending on the brightness.
    */
    public func matchingColor() -> UIColor {
        let isAlmostWhite = brighterThan(0.8)
        return isAlmostWhite ? .black : .white
    }
    
    /// http://en.wikipedia.org/wiki/YIQ
    private func YIQBrightness() -> Int {
        let componentInts = calculateRGBComponentIntegers()
        let red = componentInts.red * 299
        let green = componentInts.green * 587
        let blue = componentInts.blue * 114
        let brightness = (red + green + blue) / 1000
        
        return brightness
    }
    
    /// Calculates the RGB color components of a color as a CGFloat value, even if it is the grayscale space. Values for red, green, and blue can be of any range due to API changes. Values between 0.0 - 1.0 are in the sRGB gamut range.
    public func calculateRGBComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        var w: CGFloat = 0
        let convertedToRGBSpace = self.getRed(&r, green: &g, blue: &b, alpha: &a)
        if !convertedToRGBSpace {
            getWhite(&w, alpha: &a)
            r = w
            g = w
            b = w
        }
        return (r, g, b, a)
    }
    
    /// Calculates the RGB color components of a color as an Integer value, even if it is the grayscale space. Values between 0.0 - 255.0 are in the sRGB gamut range.
    public func calculateRGBComponentIntegers()  -> (red: Int, green: Int, blue: Int, alpha: Int){
        let components = calculateRGBComponents()
        return (Int(components.red * 255.0), Int(components.green * 255.0), Int(components.blue * 255.0), Int(components.alpha))
    }
    
    /**
    Whether or not the color brightness is higher than a provided brightness value.
    
    - parameter brightnessValue: A number that represents the brightness of a color. It ranges from 0.0 (black) to 1.0 (white).
    - return: YES if brightness is higher than the brightness value provided.
    */
    public func brighterThan(_ brightnessValue: Double) -> Bool {
        return Double(YIQBrightness()) / 255 > brightnessValue
    }
}
