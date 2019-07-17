//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// the values for common string throughout the module
struct KanvasCameraStrings {
    // MARK: - Camera Modes

    // photoModeName: used in the camera mode button
    static let photoModeName: String = NSLocalizedString("Photo", comment: "Photo camera mode")

    // gifModeName: used in the camera mode button
    static let gifModeName: String = NSLocalizedString("Loop", comment: "Gif camera mode")

    // stopMotionModeName: used in the camera mode button
    static let stopMotionModeName: String = NSLocalizedString("Capture", comment: "Stop motion camera mode")
    
    // stitchModeName: used in the camera mode button
    static let stitchModeName: String = NSLocalizedString("Stitch", comment: "Stitch camera mode")
    
    static func name(for mode: CameraMode) -> String {
        switch mode {
        case .photo: return photoModeName
        case .gif: return gifModeName
        case .stopMotion: return stopMotionModeName
        case .stitch: return stitchModeName
        }
    }
}
