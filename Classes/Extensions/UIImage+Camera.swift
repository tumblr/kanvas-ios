//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

/// Extension for loading images from the bundle
extension UIImage {
    
    /// This loads the image from the resources bundle associated with the camera
    ///
    /// - Parameter named: This is the name of the image (extension unnecessary) in the bundle
    /// - Returns: returns a UIImage if found in the bundle, or nil otherwise
    class func imageFromCameraBundle(named: String) -> UIImage? {
        guard let bundlePath = KanvasCameraStrings.bundlePath(for: CameraSettings.self) else {
                return nil
        }
        
        let bundle = Bundle(path: bundlePath)

        return UIImage(named: named, in: bundle, compatibleWith: nil)
    }
}
