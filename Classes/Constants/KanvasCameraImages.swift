//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// the images used throughout the module
struct KanvasCameraImages {
    // MARK: - Mode Selection
    static let photoModeImage: UIImage? = .none
    static let gifModeImage: UIImage? = .none
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
    static let trashClosed = UIImage.imageFromCameraBundle(named: "trashClosed")
    static let trashOpened = UIImage.imageFromCameraBundle(named: "trashOpened")
    static let circleImage = UIImage.imageFromCameraBundle(named: "circleIcon")
    static let nextImage = UIImage.imageFromCameraBundle(named: "next")
    static let postImage: UIImage? = {
        if let nextImageCGImage = nextImage?.cgImage {
            return UIImage(cgImage: nextImageCGImage, scale: 1.0, orientation: .left)
        }
        else {
            return nil
        }
    }()

    // MARK: - Filters
    static let discoballUntappedImage = UIImage.imageFromCameraBundle(named: "discoballUntapped")
    static let discoballTappedImage = UIImage.imageFromCameraBundle(named: "discoballTapped")
    static let filterTypes: [FilterType: UIImage?] = [
        .wavePool: UIImage.imageFromCameraBundle(named: "Water"),
        .plasma: UIImage.imageFromCameraBundle(named: "Plasma"),
        .emInterference: UIImage.imageFromCameraBundle(named: "EMInter"),
        .rgb: UIImage.imageFromCameraBundle(named: "RGB"),
        .lego: UIImage.imageFromCameraBundle(named: "Lego"),
        .chroma: UIImage.imageFromCameraBundle(named: "Chroma"),
        .rave: UIImage.imageFromCameraBundle(named: "Rave"),
        .mirrorTwo: UIImage.imageFromCameraBundle(named: "TwoMirror"),
        .mirrorFour: UIImage.imageFromCameraBundle(named: "FourMirror"),
        .lightLeaks: UIImage.imageFromCameraBundle(named: "Rainbow"),
        .film: UIImage.imageFromCameraBundle(named: "Noise"),
        .grayscale: UIImage.imageFromCameraBundle(named: "BW"),
        .manga: nil,
        .toon: nil,
    ]
    
    // MARK: - Editor
    static let editionOptionTypes: [EditionOption: UIImage?] = [
        .filter: UIImage.imageFromCameraBundle(named: "editorFilters"),
        .media: UIImage.imageFromCameraBundle(named: "editorMedia"),
    ]
}
