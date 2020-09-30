//
// Created by Tony Cheng on 4/18/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
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
