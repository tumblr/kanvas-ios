//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

/// Camera Modes available
///
/// - photo: Capturing photos
/// - gif: Capturing gifs, a sequence of photos
/// - stopMotion: Capturing stop motions, a sequence of images and/or videos
public enum CameraMode: Int {
    case stopMotion = 0
    case photo
    case gif
    
    private var order: Int {
        return self.rawValue
    }
    
}

// A class that defines the settings for the Kanvas Camera
@objc public final class CameraSettings: NSObject{
    // MARK: - Modes
    /**
     Enables/disables modes. Public so that other modules can change the enabled modes
     - note: Defaults to stop motion and gif.
     - note: The set can't be empty.
     */
    public var enabledModes: Set<CameraMode> {
        set {
            guard !newValue.isEmpty else {
                assertionFailure("New value for camera modes is empty")
                return
            }
            _enabledModes = newValue
        }
        get {
            return _enabledModes
        }
    }
    
    private var _enabledModes: Set<CameraMode> = DefaultCameraSettings.EnabledModes
}

private struct DefaultCameraSettings {
    
    // MARK: - Mode Selection
    static let EnabledModes: Set<CameraMode> = [.photo, .gif, .stopMotion]
    static let DefaultMode: CameraMode? = .none
    
}
