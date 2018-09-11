//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

/// The possible states of options for the camera
///
/// - flashOn: represents the camera flash or torch enabled
/// - flashOff: represents the camera flash or torch disabled
/// - frontCamera: represents the device's front (selfie) camera
/// - backCamera: presents the device's back camera
enum CameraDeviceOption {
    case flashOn
    case flashOff
    case frontCamera
    case backCamera
}

// MARK: - Setting to CameraDeviceOption conversion
fileprivate protocol CameraDeviceOptionConvertible {
    var topOption: CameraDeviceOption { get }
}

extension AVCaptureDevice.FlashMode: CameraDeviceOptionConvertible {
    /// The options for flash modes
    var topOption: CameraDeviceOption {
        switch self {
        case .off: return .flashOff
        case .on: return .flashOn
        case .auto: return .flashOff
        }
    }
}

extension AVCaptureDevice.Position: CameraDeviceOptionConvertible {
    /// The options for camera position modes
    var topOption: CameraDeviceOption {
        switch self {
        case .back: return .backCamera
        case .front: return .frontCamera
        case .unspecified: return .backCamera
        }
    }
}
