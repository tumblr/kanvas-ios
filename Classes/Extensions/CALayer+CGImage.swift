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
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { context in
            render(in: context.cgContext)
        }
        return image.cgImage
    }

}
