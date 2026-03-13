//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Delegate for handling camera input actions
protocol CameraInputControllerDelegate: AnyObject {
    /// Delegate to reset the current device zoom
    func cameraInputControllerShouldResetZoom()
    
    /// Delegate method to set zoom based on pinch
    ///
    /// - Parameters:
    ///   - gesture: the pinch gesture
    func cameraInputControllerPinched(gesture: UIPinchGestureRecognizer)

    func cameraInputControllerHasFullAccess() -> Bool
}
