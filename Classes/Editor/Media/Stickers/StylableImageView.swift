//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Image view that increases its image quality when its contentScaleFactor is modified
final class StylableImageView: UIImageView {
    
    override var contentScaleFactor: CGFloat {
        willSet {
            setScaleFactor(newValue)
        }
    }
    
    // MARK: - Scale factor
    
    /// Sets a new scale factor to update the quality of the inner image. This value represents how content in the view is mapped
    /// from the logical coordinate space (measured in points) to the device coordinate space (measured in pixels).
    /// For example, if the scale factor is 2.0, 2 pixels will be used to draw each point of the frame.
    ///
    /// - Parameter scaleFactor: the new scale factor. The value will be internally multiplied by the native scale of the device.
    /// Values must be higher than 1.0.
    func setScaleFactor(_ scaleFactor: CGFloat) {
        guard scaleFactor >= 1.0 else { return }
        let scaleFactorForDevice = scaleFactor * UIScreen.main.nativeScale
        for subview in subviews {
            subview.contentScaleFactor = scaleFactorForDevice
        }
    }
}
