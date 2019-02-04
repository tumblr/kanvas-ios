//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// the images used throughout the module
struct KanvasCameraImages {
    // MARK: - Mode Selection
    static let photoModeImage = UIImage.imageFromCameraBundle(named: "photoCameraMode")
    static let gifModeImage = UIImage.imageFromCameraBundle(named: "gifCameraMode")
    static let stopMotionModeImage: UIImage? = .none

    static func image(for mode: CameraMode) -> UIImage? {
        switch mode {
        case .photo: return photoModeImage
        case .gif: return gifModeImage
        case .stopMotion: return stopMotionModeImage
        }
    }
    // MARK: - Top options
    static let flashOnImage = UIImage.imageFromCameraBundle(named: "flashOn")
    static let flashOffImage = UIImage.imageFromCameraBundle(named: "flashOff")
    static let cameraPositionImage = UIImage.imageFromCameraBundle(named: "cameraPosition")
    static let imagePreviewOnImage = UIImage.imageFromCameraBundle(named: "imagePreviewOn")
    static let imagePreviewOffImage = UIImage.imageFromCameraBundle(named: "imagePreviewOff")
    // MARK: - General
    static let closeImage = UIImage.imageFromCameraBundle(named: "whiteCloseIcon")
    static let confirmImage = UIImage.imageFromCameraBundle(named: "confirm")
    static let backImage = UIImage.imageFromCameraBundle(named: "backArrow")
    static let deleteImage = UIImage.imageFromCameraBundle(named: "trashButton")
    static let filterImage = UIImage.imageFromCameraBundle(named: "filterIcon-smile")
}
