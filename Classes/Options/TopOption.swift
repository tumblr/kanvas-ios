//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

/// The possible states of options for the camera
///
/// - flashOn: represents the camera flash or torch enabled
/// - flashOff: represents the camera flash or torch disabled
/// - frontCamera: represents the device's front (selfie) camera
/// - backCamera: presents the device's back camera
enum TopOption {
    case flashOn
    case flashOff
    case frontCamera
    case backCamera
}

// MARK: - Setting to Top Option conversion
fileprivate protocol TopOptionConvertible {
    var topOption: TopOption { get }
}

extension AVCaptureDevice.FlashMode: TopOptionConvertible {
    var topOption: TopOption {
        switch self {
        case .off: return .flashOff
        case .on: return .flashOn
        case .auto: return .flashOff
        }
    }
}

extension AVCaptureDevice.Position: TopOptionConvertible {
    var topOption: TopOption {
        switch self {
        case .back: return .backCamera
        case .front: return .frontCamera
        case .unspecified: return .backCamera
        }
    }
}
