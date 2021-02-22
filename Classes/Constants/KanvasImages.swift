//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// the images used throughout the module
public struct KanvasImages {
    // MARK: - Mode Selection
    static let photoModeImage: UIImage? = .none
    static let loopModeImage: UIImage? = .none
    static let stopMotionModeImage: UIImage? = .none
    static let normalModeImage: UIImage? = .none
    static let stitchModeImage: UIImage? = .none
    static let gifModeImage: UIImage? = .none

    static func image(for mode: CameraMode) -> UIImage? {
        switch mode {
        case .photo: return photoModeImage
        case .loop: return loopModeImage
        case .stopMotion: return stopMotionModeImage
        case .normal: return normalModeImage
        case .stitch: return stitchModeImage
        case .gif: return gifModeImage
        }
    }
    
    // MARK: - Top options
    static let flashOnImage = UIImage.imageFromCameraBundle(named: "flashOn")
    static let flashOffImage = UIImage.imageFromCameraBundle(named: "flashOff")
    static let cameraFlashOnImage = UIImage.imageFromCameraBundle(named: "cameraFlashOn")
    static let cameraFlashOffImage = UIImage.imageFromCameraBundle(named: "cameraFlashOff")
    static let cameraPositionImage = UIImage.imageFromCameraBundle(named: "cameraPosition")
    static let cameraRotateImage = UIImage.imageFromCameraBundle(named: "cameraRotate")
    static let imagePreviewOnImage = UIImage.imageFromCameraBundle(named: "imagePreviewOn")
    static let imagePreviewOffImage = UIImage.imageFromCameraBundle(named: "imagePreviewOff")
    static let ghostFrameOnImage = UIImage.imageFromCameraBundle(named: "ghostFrameOn")
    static let ghostFrameOffImage = UIImage.imageFromCameraBundle(named: "ghostFrameOff")
    
    
    // MARK: - General
    static let closeImage = UIImage.imageFromCameraBundle(named: "whiteCloseIcon")
    static let crossImage = UIImage.imageFromCameraBundle(named: "cross")
    static let longCheckmarkImage = UIImage.imageFromCameraBundle(named: "longCheckmark")
    static let backImage = UIImage.imageFromCameraBundle(named: "back")
    static let backArrowImage = UIImage.imageFromCameraBundle(named: "backArrow")
    static let chevron = UIImage.imageFromCameraBundle(named: "chevron")
    static let forwardImage = UIImage.imageFromCameraBundle(named: "forwardArrow")
    static let trashClosed = UIImage.imageFromCameraBundle(named: "trashClosed")
    static let trashOpened = UIImage.imageFromCameraBundle(named: "trashOpened")
    static let trashBinClosed = UIImage.imageFromCameraBundle(named: "trashBinClosed")
    static let trashBinOpened = UIImage.imageFromCameraBundle(named: "trashBinOpened")
    static let circleImage = UIImage.imageFromCameraBundle(named: "circleIcon")
    static let nextArrowImage = UIImage.imageFromCameraBundle(named: "nextArrow")
    static let saveImage = UIImage.imageFromCameraBundle(named: "save")
    static let cogImage = UIImage.imageFromCameraBundle(named: "cog")
    static let tagImage = UIImage.imageFromCameraBundle(named: "tag")

    // MARK: - Filters
    static let filtersImage =  UIImage.imageFromCameraBundle(named: "menuFilters")
    static let filtersInvertedImage =  UIImage.imageFromCameraBundle(named: "menuFiltersInverted")
    static let discoballUntappedImage = UIImage.imageFromCameraBundle(named: "discoballUntapped")
    static let discoballTappedImage = UIImage.imageFromCameraBundle(named: "discoballTapped")
    static let filterTypes: [FilterType: UIImage?] = [
        .passthrough: UIImage.imageFromCameraBundle(named: "NoFilter"),
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

    static let editIcons: [EditionOption: [UIImage?]] = [
        .gif: [
            UIImage.imageFromCameraBundle(named: "editorGifOff"),
            UIImage.imageFromCameraBundle(named: "editorGifOn"),
        ],
        .filter: [UIImage.imageFromCameraBundle(named: "editorFilters")],
        .text: [UIImage.imageFromCameraBundle(named: "editorText")],
        .media: [UIImage.imageFromCameraBundle(named: "editorMedia")],
        .drawing: [UIImage.imageFromCameraBundle(named: "editorDraw")],
    ]
    
    static let styleIcons: [EditionOption: [UIImage?]] = [
        .gif: [
            UIImage.imageFromCameraBundle(named: "menuGifOff"),
            UIImage.imageFromCameraBundle(named: "menuGifOn"),
        ],
        .filter: [UIImage.imageFromCameraBundle(named: "menuFilters")],
        .text: [UIImage.imageFromCameraBundle(named: "menuText")],
        .media: [UIImage.imageFromCameraBundle(named: "menuMedia")],
        .drawing: [UIImage.imageFromCameraBundle(named: "menuDrawing")],
    ]
    
    static func editionOptionTypes(_ option: EditionOption, enabled: Bool) -> UIImage? {
        let index = enabled && editIcons[option]?.count == 2 ? 1 : 0
        return editIcons[option]?[index]
    }
    
    static func styleOptionTypes(_ option: EditionOption, enabled: Bool) -> UIImage? {
        let index = enabled && styleIcons[option]?.count == 2 ? 1 : 0
        return styleIcons[option]?[index]
    }
    
    // MARK: - Draw
    static let undoImage = UIImage.imageFromCameraBundle(named: "undo")
    static let undoLongImage = UIImage.imageFromCameraBundle(named: "undoLong")
    static let eraserUnselectedImage = UIImage.imageFromCameraBundle(named: "eraserUnselected")
    static let eraserSelectedImage = UIImage.imageFromCameraBundle(named: "eraserSelected")
    static let eraserOffImage = UIImage.imageFromCameraBundle(named: "eraserOff")
    static let eraserOnImage = UIImage.imageFromCameraBundle(named: "eraserOn")
    static let markerImage = UIImage.imageFromCameraBundle(named: "marker")
    static let markerRoundedImage = UIImage.imageFromCameraBundle(named: "markerRounded")
    static let sharpieImage = UIImage.imageFromCameraBundle(named: "sharpie")
    static let sharpieRoundedImage = UIImage.imageFromCameraBundle(named: "sharpieRounded")
    static let pencilImage = UIImage.imageFromCameraBundle(named: "pencil")
    static let pencilRoundedImage = UIImage.imageFromCameraBundle(named: "pencilRounded")
    static let gradientImage = UIImage.imageFromCameraBundle(named: "gradient")
    static let closeGradientImage = UIImage.imageFromCameraBundle(named: "closeGradient")
    static let closeGradientRoundedImage = UIImage.imageFromCameraBundle(named: "closeGradientRounded")
    static let eyeDropperImage = UIImage.imageFromCameraBundle(named: "eyeDropper")
    static let eyeDropperRoundedImage = UIImage.imageFromCameraBundle(named: "eyeDropperRounded")
    static let dropImage = UIImage.imageFromCameraBundle(named: "drop")
    
    // MARK: - Text
    static let fontImage = UIImage.imageFromCameraBundle(named: "font")
    static let fontBlockImage = UIImage.imageFromCameraBundle(named: "fontBlock")
    static let aligmentImages: [NSTextAlignment: UIImage?] = [
        .left: UIImage.imageFromCameraBundle(named: "leftAlignment"),
        .center: UIImage.imageFromCameraBundle(named: "centerAlignment"),
        .right: UIImage.imageFromCameraBundle(named: "rightAlignment"),
    ]
    static let aligmentRoundedImages: [NSTextAlignment: UIImage?] = [
        .left: UIImage.imageFromCameraBundle(named: "leftAlignmentRounded"),
        .center: UIImage.imageFromCameraBundle(named: "centerAlignmentRounded"),
        .right: UIImage.imageFromCameraBundle(named: "rightAlignmentRounded"),
    ]
    static let highlightUnselected = UIImage.imageFromCameraBundle(named: "highlightUnselected")
    static let highlightRoundedUnselected = UIImage.imageFromCameraBundle(named: "highlightRoundedUnselected")
    static let highlightSelected = UIImage.imageFromCameraBundle(named: "highlightSelected")
    static let highlightRoundedSelected = UIImage.imageFromCameraBundle(named: "highlightRoundedSelected")
    static func highlightImage(for selected: Bool) -> UIImage? {
        return selected ? highlightSelected : highlightUnselected
    }
    static func highlightRoundedImage(for selected: Bool) -> UIImage? {
        return selected ? highlightSelected : highlightUnselected
    }
    
    // MARK: - Media Picker
    static let imageThumbnail = UIImage.imageFromCameraBundle(named: "imageThumbnail")
    
    // MARK: - GIF Maker
    static let trimOff = UIImage.imageFromCameraBundle(named: "trimOff")
    static let trimOn = UIImage.imageFromCameraBundle(named: "trimOn")
    static let speedOff = UIImage.imageFromCameraBundle(named: "speedOff")
    static let speedOn = UIImage.imageFromCameraBundle(named: "speedOn")
    
    // MARK: - Camera Permissions
    static let permissionCheckmark = UIImage.imageFromCameraBundle(named: "checkmark")

    let nextImage: UIImage?
    let confirmImage: UIImage?
    let editorConfirmImage: UIImage?

    public static var shared = KanvasImages(confirmImage: UIImage.imageFromCameraBundle(named: "confirm"),
                                    editorConfirmImage: UIImage.imageFromCameraBundle(named: "editorConfirm"),
                                     nextImage: UIImage.imageFromCameraBundle(named: "next"))

    public init(confirmImage: UIImage?,
         editorConfirmImage: UIImage?,
         nextImage: UIImage?) {
        self.confirmImage = confirmImage
        self.editorConfirmImage = editorConfirmImage
        self.nextImage = nextImage
    }
}
