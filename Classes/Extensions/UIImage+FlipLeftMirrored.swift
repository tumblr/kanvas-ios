//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

/// Extension for image flipping
extension UIImage {
    
    /// Rotates an image 90° clockwise and flips it horizontally
    ///
    /// - Returns: a copy of the original UIImage that has been rotated 90° clockwise and flipped horizontally
    public func flipLeftMirrored() -> UIImage? {
        guard let coreGraphicsImage = cgImage else { return nil }
        return UIImage(cgImage: coreGraphicsImage, scale: 1.0, orientation: .leftMirrored)
    }
}
