//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Extension for obtaining the dominant colors of a UIImage
extension UIImage {
    
    /// Gets the dominant colors of an image
    ///
    /// - Parameter count: Number of colors wanted
    /// - Returns: returns a collection with the dominant colors
    func getDominantColors(count: Int) -> [UIColor] {
        guard let colorPalette = ColorThief.getPalette(from: self, colorCount: count, quality: 10, ignoreWhite: false) else {
            return []
        }
        
        return colorPalette.map { $0.makeUIColor() }
    }
}
