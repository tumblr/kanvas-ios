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

    func invert() -> UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }
        let image = CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIColorInvert") else {
            return nil
        }
        filter.setDefaults()
        filter.setValue(image, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        guard let newCGImage = context.createCGImage(filter.outputImage!, from: image.extent) else {
            return nil
        }
        return UIImage(cgImage: newCGImage)
    }

    func overlayOnTopOf(_ image: UIImage?) -> UIImage? {
        guard let image = image else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(in: CGRect(origin: .zero, size: size))
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
