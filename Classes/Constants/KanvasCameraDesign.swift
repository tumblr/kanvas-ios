//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

public struct KanvasCameraDesign {
    
    var isRedesign: Bool
    
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
    let trashViewSize: CGFloat
    let trashViewBorderImageSize: CGFloat
    
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
                trashViewSize: CGFloat,
                trashViewBorderImageSize: CGFloat,
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
        self.trashViewSize = trashViewSize
        self.trashViewBorderImageSize = trashViewBorderImageSize
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
        self.mediaClipsCollectionCellClipHeight = mediaClipsCollectionCellClipHeight
        self.mediaClipsCollectionCellClipWidth = mediaClipsCollectionCellClipWidth
        self.mediaClipsCollectionCellBorderWidth = mediaClipsCollectionCellBorderWidth
        self.mediaClipsCollectionCellCornerRadius = mediaClipsCollectionCellCornerRadius
        self.mediaClipsCollectionCellClipAlpha = mediaClipsCollectionCellClipAlpha
    }
    
    public static var shared: KanvasCameraDesign = {
        return KanvasCameraDesign.cameraDimensions
    }()
    
    
    public static var cameraDimensions: KanvasCameraDesign = {
        return KanvasCameraDesign(
            isRedesign: false,
            cameraViewButtonBackgroundColor: .clear,
            cameraViewButtonInvertedBackgroundColor: .clear,
            cameraViewOptionVerticalMargin: 24,
            cameraViewOptionHorizontalMargin: 24,
            cameraViewOptionButtonSize: 26.5,
            cameraViewOptionSpacing: 33,
            cameraViewNextImage: KanvasCameraImages.forwardImage,
            cameraViewCloseImage: KanvasCameraImages.closeImage,
            shootButtonImageWidth: 30,
            shootButtonInnerCircleImageWidth: 64,
            shootButtonOuterCircleImageWidth: 95,
            trashViewSize: 98,
            trashViewBorderImageSize: 90,
            cameraFilterCollectionCellCircleDiameter: 72,
            cameraFilterCollectionCellCircleMaxDiameter: 96.1,
            cameraOptionFlashOnImage: KanvasCameraImages.flashOnImage,
            cameraOptionFlashOffImage: KanvasCameraImages.flashOffImage,
            cameraOptionGhostFrameOnImage: KanvasCameraImages.imagePreviewOnImage,
            cameraOptionGhostFrameOffImage: KanvasCameraImages.imagePreviewOffImage,
            cameraOptionCameraPositionImage: KanvasCameraImages.cameraPositionImage,
            filterSettingsViewIconSize: 39,
            filterSettingsViewPadding: 4,
            filterSettingsViewFiltersOffImage: KanvasCameraImages.discoballUntappedImage,
            filterSettingsViewFiltersOnImage: KanvasCameraImages.discoballTappedImage,
            mediaClipsCollectionControllerLeftInset: 11,
            mediaClipsCollectionControllerRightInset: 11,
            mediaClipsCollectionViewFadeOutGradientLocations: [0, 0.05, 0.9, 1.0],
            mediaClipsEditorViewButtonLeadingMargin: 16,
            mediaClipsEditorViewButtonTrailingMargin: 16,
            mediaClipsEditorViewTopPadding: 6,
            mediaClipsEditorViewBottomPadding: 6 + (Device.belongsToIPhoneXGroup ? 28 : 0),
            mediaClipsEditorViewNextButtonCenterYOffset: 3,
            mediaClipsCollectionCellClipHeight: 60,
            mediaClipsCollectionCellClipWidth: 40,
            mediaClipsCollectionCellBorderWidth: 1.1,
            mediaClipsCollectionCellCornerRadius: 8,
            mediaClipsCollectionCellClipAlpha: 0.5
        )
    }()
    
    
    public static var cameraRedesignDimensions: KanvasCameraDesign = {
        return KanvasCameraDesign(
            isRedesign: true,
            cameraViewButtonBackgroundColor: UIColor.black.withAlphaComponent(0.4),
            cameraViewButtonInvertedBackgroundColor: UIColor.white,
            cameraViewOptionVerticalMargin: 28,
            cameraViewOptionHorizontalMargin: 16,
            cameraViewOptionButtonSize: 48,
            cameraViewOptionSpacing: 24,
            cameraViewNextImage: KanvasCameraImages.nextArrowImage,
            cameraViewCloseImage: KanvasCameraImages.crossImage,
            shootButtonImageWidth: 25,
            shootButtonInnerCircleImageWidth: 56.9,
            shootButtonOuterCircleImageWidth: 84.4,
            trashViewSize: 87.1,
            trashViewBorderImageSize: 80,
            cameraFilterCollectionCellCircleDiameter: 64,
            cameraFilterCollectionCellCircleMaxDiameter: 85.42,
            cameraOptionFlashOnImage: KanvasCameraImages.cameraFlashOnImage,
            cameraOptionFlashOffImage: KanvasCameraImages.cameraFlashOffImage,
            cameraOptionGhostFrameOnImage: KanvasCameraImages.ghostFrameOnImage,
            cameraOptionGhostFrameOffImage: KanvasCameraImages.ghostFrameOffImage,
            cameraOptionCameraPositionImage: KanvasCameraImages.cameraRotateImage,
            filterSettingsViewIconSize: 48,
            filterSettingsViewPadding: 8,
            filterSettingsViewFiltersOffImage: KanvasCameraImages.filtersImage,
            filterSettingsViewFiltersOnImage: KanvasCameraImages.filtersInvertedImage,
            mediaClipsCollectionControllerLeftInset: 28,
            mediaClipsCollectionControllerRightInset: 14,
            mediaClipsCollectionViewFadeOutGradientLocations: [0, 0.05, 0.95, 1.0],
            mediaClipsEditorViewButtonLeadingMargin: 7,
            mediaClipsEditorViewButtonTrailingMargin: 28,
            mediaClipsEditorViewTopPadding: 11,
            mediaClipsEditorViewBottomPadding: Device.belongsToIPhoneXGroup ? 29 : 15,
            mediaClipsEditorViewNextButtonCenterYOffset: 0,
            mediaClipsCollectionCellClipHeight: 48,
            mediaClipsCollectionCellClipWidth: 33,
            mediaClipsCollectionCellBorderWidth: 2,
            mediaClipsCollectionCellCornerRadius: 4,
            mediaClipsCollectionCellClipAlpha: 0.87
        )
    }()
}
