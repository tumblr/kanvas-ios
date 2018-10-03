//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// the values for common string throughout the module
struct KanvasCameraStrings {
    // MARK: - Camera Modes

    // PhotoModeName: used in the camera mode button
    static let PhotoModeName: String = NSLocalizedString("Photo", comment: "Photo camera mode")

    // GifModeName: used in the camera mode button
    static let GifModeName: String = NSLocalizedString("Loop", comment: "Gif camera mode")

    // StopMotionModeName: used in the camera mode button
    static let StopMotionModeName: String = NSLocalizedString("Capture", comment: "Stop motion camera mode")

    static func name(for mode: CameraMode) -> String {
        switch mode {
        case .photo: return PhotoModeName
        case .gif: return GifModeName
        case .stopMotion: return StopMotionModeName
        }
    }
}
