//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

extension UIImage {
    convenience init?(color: UIColor) {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let maybeImage = UIGraphicsGetImageFromCurrentImageContext()
        guard let image = maybeImage, let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage)
        UIGraphicsEndImageContext()
    }
}
