//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

public struct KanvasCameraDesign {
    
    // MARK: - General
    public let isRedesign: Bool
    
    // MARK: - Camera View
    let cameraViewButtonBackgroundColor: UIColor
    let cameraViewButtonInvertedBackgroundColor: UIColor
    let cameraViewOptionVerticalMargin: CGFloat
    let cameraViewOptionHorizontalMargin: CGFloat
    let cameraViewOptionButtonSize: CGFloat
    let cameraViewOptionSpacing: CGFloat
    let cameraViewNextImage: UIImage?
    let cameraViewCloseImage: UIImage?
    
    // MARK: - ShootButtonView
    let shootButtonImageWidth: CGFloat
    let shootButtonInnerCircleImageWidth: CGFloat
    let shootButtonOuterCircleImageWidth: CGFloat
    
    // MARK: - TrashView
    let trashViewOpenedImage: UIImage?
    let trashViewClosedImage: UIImage?
    let trashViewSize: CGFloat
    let trashViewBorderImageSize: CGFloat
    let trashViewClosedIconHeight: CGFloat
    let trashViewClosedIconWidth: CGFloat
    let trashViewOpenedIconHeight: CGFloat
    let trashViewOpenedIconWidth: CGFloat
    let trashViewOpenedIconCenterYOffset: CGFloat
    let trashViewOpenedIconCenterXOffset: CGFloat
    
    
    // MARK: - CameraFilterCollectionCell
    let cameraFilterCollectionCellCircleDiameter: CGFloat
    let cameraFilterCollectionCellCircleMaxDiameter: CGFloat
    
    // MARK: - CameraOption
    let cameraOptionFlashOnImage: UIImage?
    let cameraOptionFlashOffImage: UIImage?
    let cameraOptionGhostFrameOnImage: UIImage?
    let cameraOptionGhostFrameOffImage: UIImage?
    let cameraOptionCameraPositionImage: UIImage?
    
    // MARK: - FilterSettingsView
    let filterSettingsViewIconSize: CGFloat
    let filterSettingsViewPadding: CGFloat
    let filterSettingsViewFiltersOffImage: UIImage?
    let filterSettingsViewFiltersOnImage: UIImage?
    
    // MARK: - MediaClipsCollectionController
    let mediaClipsCollectionControllerLeftInset: CGFloat
    let mediaClipsCollectionControllerRightInset: CGFloat
    
    // MARK: - MediaClipsCollectionView
    let mediaClipsCollectionViewFadeOutGradientLocations: [NSNumber]
    
    // MARK: - MediaClipsEditorView
    let mediaClipsEditorViewButtonLeadingMargin: CGFloat
    let mediaClipsEditorViewButtonTrailingMargin: CGFloat
    let mediaClipsEditorViewTopPadding: CGFloat
    let mediaClipsEditorViewBottomPadding: CGFloat
    let mediaClipsEditorViewNextButtonCenterYOffset: CGFloat
    let mediaClipsEditorViewNextImage: UIImage?
    
    
    // MARK: - MediaClipsCollectionCell
    let mediaClipsCollectionCellClipHeight: CGFloat
    let mediaClipsCollectionCellClipWidth: CGFloat
    let mediaClipsCollectionCellBorderWidth: CGFloat
    let mediaClipsCollectionCellCornerRadius: CGFloat
    let mediaClipsCollectionCellClipAlpha: CGFloat
    
    public init(isRedesign: Bool,
                cameraViewButtonBackgroundColor: UIColor,
                cameraViewButtonInvertedBackgroundColor: UIColor,
                cameraViewOptionVerticalMargin: CGFloat,
                cameraViewOptionHorizontalMargin: CGFloat,
                cameraViewOptionButtonSize: CGFloat,
                cameraViewOptionSpacing: CGFloat,
                cameraViewNextImage: UIImage?,
                cameraViewCloseImage: UIImage?,
                shootButtonImageWidth: CGFloat,
                shootButtonInnerCircleImageWidth: CGFloat,
                shootButtonOuterCircleImageWidth: CGFloat,
                trashViewOpenedImage: UIImage?,
                trashViewClosedImage: UIImage?,
                trashViewSize: CGFloat,
                trashViewBorderImageSize: CGFloat,
                trashViewClosedIconHeight: CGFloat,
                trashViewClosedIconWidth: CGFloat,
                trashViewOpenedIconHeight: CGFloat,
                trashViewOpenedIconWidth: CGFloat,
                trashViewOpenedIconCenterYOffset: CGFloat,
                trashViewOpenedIconCenterXOffset: CGFloat,
                cameraFilterCollectionCellCircleDiameter: CGFloat,
                cameraFilterCollectionCellCircleMaxDiameter: CGFloat,
                cameraOptionFlashOnImage: UIImage?,
                cameraOptionFlashOffImage: UIImage?,
                cameraOptionGhostFrameOnImage: UIImage?,
                cameraOptionGhostFrameOffImage: UIImage?,
                cameraOptionCameraPositionImage: UIImage?,
                filterSettingsViewIconSize: CGFloat,
                filterSettingsViewPadding: CGFloat,
                filterSettingsViewFiltersOffImage: UIImage?,
                filterSettingsViewFiltersOnImage: UIImage?,
                mediaClipsCollectionControllerLeftInset: CGFloat,
                mediaClipsCollectionControllerRightInset: CGFloat,
                mediaClipsCollectionViewFadeOutGradientLocations: [NSNumber],
                mediaClipsEditorViewButtonLeadingMargin: CGFloat,
                mediaClipsEditorViewButtonTrailingMargin: CGFloat,
                mediaClipsEditorViewTopPadding: CGFloat,
                mediaClipsEditorViewBottomPadding: CGFloat,
                mediaClipsEditorViewNextButtonCenterYOffset: CGFloat,
                mediaClipsEditorViewNextImage: UIImage?,
                mediaClipsCollectionCellClipHeight: CGFloat,
                mediaClipsCollectionCellClipWidth: CGFloat,
                mediaClipsCollectionCellBorderWidth: CGFloat,
                mediaClipsCollectionCellCornerRadius: CGFloat,
                mediaClipsCollectionCellClipAlpha: CGFloat) {
        
        self.isRedesign = isRedesign
        self.cameraViewOptionVerticalMargin = cameraViewOptionVerticalMargin
        self.cameraViewOptionHorizontalMargin = cameraViewOptionHorizontalMargin
        self.cameraViewOptionButtonSize = cameraViewOptionButtonSize
        self.cameraViewOptionSpacing = cameraViewOptionSpacing
        self.cameraViewNextImage = cameraViewNextImage
        self.cameraViewCloseImage = cameraViewCloseImage
        self.shootButtonImageWidth = shootButtonImageWidth
        self.shootButtonInnerCircleImageWidth = shootButtonInnerCircleImageWidth
        self.shootButtonOuterCircleImageWidth = shootButtonOuterCircleImageWidth
        self.trashViewOpenedImage = trashViewOpenedImage
        self.trashViewClosedImage = trashViewClosedImage
        self.trashViewSize = trashViewSize
        self.trashViewBorderImageSize = trashViewBorderImageSize
        self.trashViewClosedIconHeight = trashViewClosedIconHeight
        self.trashViewClosedIconWidth = trashViewClosedIconWidth
        self.trashViewOpenedIconHeight = trashViewOpenedIconHeight
        self.trashViewOpenedIconWidth = trashViewOpenedIconWidth
        self.trashViewOpenedIconCenterYOffset = trashViewOpenedIconCenterYOffset
        self.trashViewOpenedIconCenterXOffset = trashViewOpenedIconCenterXOffset
        self.cameraFilterCollectionCellCircleDiameter = cameraFilterCollectionCellCircleDiameter
        self.cameraFilterCollectionCellCircleMaxDiameter = cameraFilterCollectionCellCircleMaxDiameter
        self.cameraOptionFlashOnImage = cameraOptionFlashOnImage
        self.cameraOptionFlashOffImage = cameraOptionFlashOffImage
        self.cameraOptionGhostFrameOnImage = cameraOptionGhostFrameOnImage
        self.cameraOptionGhostFrameOffImage = cameraOptionGhostFrameOffImage
        self.cameraOptionCameraPositionImage = cameraOptionCameraPositionImage
        self.cameraViewButtonBackgroundColor = cameraViewButtonBackgroundColor
        self.cameraViewButtonInvertedBackgroundColor = cameraViewButtonInvertedBackgroundColor
        self.filterSettingsViewIconSize = filterSettingsViewIconSize
        self.filterSettingsViewPadding = filterSettingsViewPadding
        self.filterSettingsViewFiltersOffImage = filterSettingsViewFiltersOffImage
        self.filterSettingsViewFiltersOnImage = filterSettingsViewFiltersOnImage
        self.mediaClipsCollectionControllerLeftInset = mediaClipsCollectionControllerLeftInset
        self.mediaClipsCollectionControllerRightInset = mediaClipsCollectionControllerRightInset
        self.mediaClipsCollectionViewFadeOutGradientLocations = mediaClipsCollectionViewFadeOutGradientLocations
        self.mediaClipsEditorViewButtonLeadingMargin = mediaClipsEditorViewButtonLeadingMargin
        self.mediaClipsEditorViewButtonTrailingMargin = mediaClipsEditorViewButtonTrailingMargin
        self.mediaClipsEditorViewTopPadding = mediaClipsEditorViewTopPadding
        self.mediaClipsEditorViewBottomPadding = mediaClipsEditorViewBottomPadding
        self.mediaClipsEditorViewNextButtonCenterYOffset = mediaClipsEditorViewNextButtonCenterYOffset
        self.mediaClipsEditorViewNextImage = mediaClipsEditorViewNextImage
        self.mediaClipsCollectionCellClipHeight = mediaClipsCollectionCellClipHeight
        self.mediaClipsCollectionCellClipWidth = mediaClipsCollectionCellClipWidth
        self.mediaClipsCollectionCellBorderWidth = mediaClipsCollectionCellBorderWidth
        self.mediaClipsCollectionCellCornerRadius = mediaClipsCollectionCellCornerRadius
        self.mediaClipsCollectionCellClipAlpha = mediaClipsCollectionCellClipAlpha
    }
    
    public static var shared: KanvasCameraDesign = {
        return KanvasCameraDesign.cameraDefaultDesign
    }()
    
    
    public static var cameraDefaultDesign: KanvasCameraDesign = {
        return KanvasCameraDesign(
            isRedesign: false,
            cameraViewButtonBackgroundColor: .clear,
            cameraViewButtonInvertedBackgroundColor: .clear,
            cameraViewOptionVerticalMargin: 24,
            cameraViewOptionHorizontalMargin: 24,
            cameraViewOptionButtonSize: 26.5,
            cameraViewOptionSpacing: 33,
            cameraViewNextImage: UIImage.imageFromCameraBundle(named: "forwardArrow"),
            cameraViewCloseImage: UIImage.imageFromCameraBundle(named: "whiteCloseIcon"),
            shootButtonImageWidth: 30,
            shootButtonInnerCircleImageWidth: 64,
            shootButtonOuterCircleImageWidth: 95,
            trashViewOpenedImage: UIImage.imageFromCameraBundle(named: "trashOpened"),
            trashViewClosedImage: UIImage.imageFromCameraBundle(named: "trashClosed"),
            trashViewSize: 98,
            trashViewBorderImageSize: 90,
            trashViewClosedIconHeight: 33,
            trashViewClosedIconWidth: 33,
            trashViewOpenedIconHeight: 38,
            trashViewOpenedIconWidth: 38,
            trashViewOpenedIconCenterYOffset: 2.5,
            trashViewOpenedIconCenterXOffset: 0,
            cameraFilterCollectionCellCircleDiameter: 72,
            cameraFilterCollectionCellCircleMaxDiameter: 96.1,
            cameraOptionFlashOnImage: UIImage.imageFromCameraBundle(named: "flashOn"),
            cameraOptionFlashOffImage: UIImage.imageFromCameraBundle(named: "flashOff"),
            cameraOptionGhostFrameOnImage: UIImage.imageFromCameraBundle(named: "imagePreviewOn"),
            cameraOptionGhostFrameOffImage: UIImage.imageFromCameraBundle(named: "imagePreviewOff"),
            cameraOptionCameraPositionImage: UIImage.imageFromCameraBundle(named: "cameraPosition"),
            filterSettingsViewIconSize: 39,
            filterSettingsViewPadding: 4,
            filterSettingsViewFiltersOffImage: UIImage.imageFromCameraBundle(named: "discoballUntapped"),
            filterSettingsViewFiltersOnImage: UIImage.imageFromCameraBundle(named: "discoballTapped"),
            mediaClipsCollectionControllerLeftInset: 11,
            mediaClipsCollectionControllerRightInset: 11,
            mediaClipsCollectionViewFadeOutGradientLocations: [0, 0.05, 0.9, 1.0],
            mediaClipsEditorViewButtonLeadingMargin: 16,
            mediaClipsEditorViewButtonTrailingMargin: 16,
            mediaClipsEditorViewTopPadding: 6,
            mediaClipsEditorViewBottomPadding: 6 + (Device.belongsToIPhoneXGroup ? 28 : 0),
            mediaClipsEditorViewNextButtonCenterYOffset: 3,
            mediaClipsEditorViewNextImage: UIImage.imageFromCameraBundle(named: "next"),
            mediaClipsCollectionCellClipHeight: 60,
            mediaClipsCollectionCellClipWidth: 40,
            mediaClipsCollectionCellBorderWidth: 1.1,
            mediaClipsCollectionCellCornerRadius: 8,
            mediaClipsCollectionCellClipAlpha: 0.5
        )
    }()
    
    
    public static var cameraRedesign: KanvasCameraDesign = {
        return KanvasCameraDesign(
            isRedesign: true,
            cameraViewButtonBackgroundColor: UIColor.black.withAlphaComponent(0.4),
            cameraViewButtonInvertedBackgroundColor: UIColor.white,
            cameraViewOptionVerticalMargin: 28,
            cameraViewOptionHorizontalMargin: 16,
            cameraViewOptionButtonSize: 48,
            cameraViewOptionSpacing: 24,
            cameraViewNextImage: UIImage.imageFromCameraBundle(named: "nextArrow"),
            cameraViewCloseImage: UIImage.imageFromCameraBundle(named: "cross"),
            shootButtonImageWidth: 25,
            shootButtonInnerCircleImageWidth: 56.9,
            shootButtonOuterCircleImageWidth: 84.4,
            trashViewOpenedImage: UIImage.imageFromCameraBundle(named: "trashBinOpened"),
            trashViewClosedImage: UIImage.imageFromCameraBundle(named: "trashBinClosed"),
            trashViewSize: 87.1,
            trashViewBorderImageSize: 80,
            trashViewClosedIconHeight: 28,
            trashViewClosedIconWidth: 24,
            trashViewOpenedIconHeight: 31.76,
            trashViewOpenedIconWidth: 23.29,
            trashViewOpenedIconCenterYOffset: 1,
            trashViewOpenedIconCenterXOffset: 0.9,
            cameraFilterCollectionCellCircleDiameter: 64,
            cameraFilterCollectionCellCircleMaxDiameter: 85.42,
            cameraOptionFlashOnImage: UIImage.imageFromCameraBundle(named: "cameraFlashOn"),
            cameraOptionFlashOffImage: UIImage.imageFromCameraBundle(named: "cameraFlashOff"),
            cameraOptionGhostFrameOnImage: UIImage.imageFromCameraBundle(named: "ghostFrameOn"),
            cameraOptionGhostFrameOffImage: UIImage.imageFromCameraBundle(named: "ghostFrameOff"),
            cameraOptionCameraPositionImage: UIImage.imageFromCameraBundle(named: "cameraRotate"),
            filterSettingsViewIconSize: 48,
            filterSettingsViewPadding: 8,
            filterSettingsViewFiltersOffImage: UIImage.imageFromCameraBundle(named: "menuFilters"),
            filterSettingsViewFiltersOnImage: UIImage.imageFromCameraBundle(named: "menuFiltersInverted"),
            mediaClipsCollectionControllerLeftInset: 28,
            mediaClipsCollectionControllerRightInset: 14,
            mediaClipsCollectionViewFadeOutGradientLocations: [0, 0.05, 0.95, 1.0],
            mediaClipsEditorViewButtonLeadingMargin: 7,
            mediaClipsEditorViewButtonTrailingMargin: 28,
            mediaClipsEditorViewTopPadding: 11,
            mediaClipsEditorViewBottomPadding: Device.belongsToIPhoneXGroup ? 29 : 15,
            mediaClipsEditorViewNextButtonCenterYOffset: 0,
            mediaClipsEditorViewNextImage: UIImage.imageFromCameraBundle(named: "nextArrow"),
            mediaClipsCollectionCellClipHeight: 48,
            mediaClipsCollectionCellClipWidth: 33,
            mediaClipsCollectionCellBorderWidth: 2,
            mediaClipsCollectionCellCornerRadius: 4,
            mediaClipsCollectionCellClipAlpha: 0.87
        )
    }()
}
