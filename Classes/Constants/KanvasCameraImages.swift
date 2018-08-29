//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// the images used throughout the module
struct KanvasCameraImages {
    // MARK: - Mode Selection
    static let PhotoModeImage = UIImage.imageFromCameraBundle(named: "photoCameraMode")
    static let GifModeImage = UIImage.imageFromCameraBundle(named: "gifCameraMode")
    static let StopMotionModeImage: UIImage? = .none

    static func image(for mode: CameraMode) -> UIImage? {
        switch mode {
        case .photo: return PhotoModeImage
        case .gif: return GifModeImage
        case .stopMotion: return StopMotionModeImage
        }
    }
    // MARK: - Top options
    static let FlashOnImage = UIImage.imageFromCameraBundle(named: "flashOn")
    static let FlashOffImage = UIImage.imageFromCameraBundle(named: "flashOff")
    static let CameraPositionImage = UIImage.imageFromCameraBundle(named: "cameraPosition")
    // MARK: - General
    static let CloseImage = UIImage.imageFromCameraBundle(named: "whiteCloseIcon")
    static let ConfirmImage = UIImage.imageFromCameraBundle(named: "confirm")
    static let BackImage = UIImage.imageFromCameraBundle(named: "backArrow")
    static let UndoImage = UIImage.imageFromCameraBundle(named: "undoButton")
    static let NextImage = UIImage.imageFromCameraBundle(named: "nextButton")
}
