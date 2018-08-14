//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

/// Extension for loading images from the bundle
extension UIImage {
    class func imageFromCameraBundle(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle(for: CameraCoordinator.self), compatibleWith: nil)
    }
}
