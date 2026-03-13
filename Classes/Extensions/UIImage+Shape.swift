//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

/// Extension for creating shapes
extension UIImage {
    
    /// Creates a circle.
    ///
    /// - Parameters
    ///  - diameter: the diameter of the circle.
    ///  - color: the color of the circle..
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: rect)

        context.restoreGState()
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        UIGraphicsEndImageContext()

        return image
    }
}
