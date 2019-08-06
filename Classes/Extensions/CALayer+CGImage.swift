//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreGraphics
import UIKit

/// Extension that converts CALayer into a CGImage
extension CALayer {

    func cgImage() -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image?.cgImage
    }

}
