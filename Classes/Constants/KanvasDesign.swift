//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

public struct KanvasDesign {
    
    // MARK: - General
    public let isBottomPicker: Bool
    
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
    let shootButtonBorderWidth: CGFloat
    let shootButtonMaximumWidth: CGFloat
    
    // MARK: - TrashView
    let trashViewOpenedImage: UIImage?
    let trashViewClosedImage: UIImage?
    let trashViewSize: CGFloat
    let trashViewBorderImageSize: CGFloat
    let trashViewBorderWidth: CGFloat
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
    let filterSettingsViewButtonBackgroundColor: UIColor
    let filterSettingsViewButtonBackgroundInvertedColor: UIColor
    
    // MARK: - FilterCollectionInnerCell
    let filterCollectionInnerCellBorderWidth: CGFloat
    
    // MARK: - MediaClipsCollectionController
    let mediaClipsCollectionControllerLeftInset: CGFloat
    let mediaClipsCollectionControllerRightInset: CGFloat
    
    // MARK: - MediaClipsCollectionView
    let mediaClipsCollectionViewFadeOutGradientLocations: [NSNumber]
    
    // MARK: - MediaClipsEditorView
    let mediaClipsEditorViewBackgroundColor: UIColor
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
    let mediaClipsCollectionCellSelectedBorderWidth: CGFloat
    let mediaClipsCollectionCellCornerRadius: CGFloat
    let mediaClipsCollectionCellClipAlpha: CGFloat
    let mediaClipsCollectionCellFont: UIFont
    let mediaClipsCollectionCellLabelVerticalPadding: CGFloat
    let mediaClipsCollectionCellLabelHorizontalPadding: CGFloat
    
    public init(isBottomPicker: Bool,
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
                shootButtonBorderWidth: CGFloat,
                shootButtonMaximumWidth: CGFloat,
                trashViewOpenedImage: UIImage?,
                trashViewClosedImage: UIImage?,
                trashViewSize: CGFloat,
                trashViewBorderImageSize: CGFloat,
                trashViewBorderWidth: CGFloat,
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
                filterSettingsViewButtonBackgroundColor: UIColor,
                filterSettingsViewButtonBackgroundInvertedColor: UIColor,
                filterCollectionInnerCellBorderWidth: CGFloat,
                mediaClipsCollectionControllerLeftInset: CGFloat,
                mediaClipsCollectionControllerRightInset: CGFloat,
                mediaClipsCollectionViewFadeOutGradientLocations: [NSNumber],
                mediaClipsEditorViewBackgroundColor: UIColor,
                mediaClipsEditorViewButtonLeadingMargin: CGFloat,
                mediaClipsEditorViewButtonTrailingMargin: CGFloat,
                mediaClipsEditorViewTopPadding: CGFloat,
                mediaClipsEditorViewBottomPadding: CGFloat,
                mediaClipsEditorViewNextButtonCenterYOffset: CGFloat,
                mediaClipsEditorViewNextImage: UIImage?,
                mediaClipsCollectionCellClipHeight: CGFloat,
                mediaClipsCollectionCellClipWidth: CGFloat,
                mediaClipsCollectionCellBorderWidth: CGFloat,
                mediaClipsCollectionCellSelectedBorderWidth: CGFloat,
                mediaClipsCollectionCellCornerRadius: CGFloat,
                mediaClipsCollectionCellClipAlpha: CGFloat,
                mediaClipsCollectionCellFont: UIFont,
                mediaClipsCollectionCellLabelVerticalPadding: CGFloat,
                mediaClipsCollectionCellLabelHorizontalPadding: CGFloat) {
        
        self.isBottomPicker = isBottomPicker
        self.cameraViewOptionVerticalMargin = cameraViewOptionVerticalMargin
        self.cameraViewOptionHorizontalMargin = cameraViewOptionHorizontalMargin
        self.cameraViewOptionButtonSize = cameraViewOptionButtonSize
        self.cameraViewOptionSpacing = cameraViewOptionSpacing
        self.cameraViewNextImage = cameraViewNextImage
        self.cameraViewCloseImage = cameraViewCloseImage
        self.shootButtonImageWidth = shootButtonImageWidth
        self.shootButtonInnerCircleImageWidth = shootButtonInnerCircleImageWidth
        self.shootButtonOuterCircleImageWidth = shootButtonOuterCircleImageWidth
        self.shootButtonBorderWidth = shootButtonBorderWidth
        self.shootButtonMaximumWidth = shootButtonMaximumWidth
        self.trashViewOpenedImage = trashViewOpenedImage
        self.trashViewClosedImage = trashViewClosedImage
        self.trashViewSize = trashViewSize
        self.trashViewBorderImageSize = trashViewBorderImageSize
        self.trashViewBorderWidth = trashViewBorderWidth
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
        self.filterSettingsViewButtonBackgroundColor = filterSettingsViewButtonBackgroundColor
        self.filterSettingsViewButtonBackgroundInvertedColor = filterSettingsViewButtonBackgroundInvertedColor
        self.filterCollectionInnerCellBorderWidth = filterCollectionInnerCellBorderWidth
        self.mediaClipsCollectionControllerLeftInset = mediaClipsCollectionControllerLeftInset
        self.mediaClipsCollectionControllerRightInset = mediaClipsCollectionControllerRightInset
        self.mediaClipsCollectionViewFadeOutGradientLocations = mediaClipsCollectionViewFadeOutGradientLocations
        self.mediaClipsEditorViewBackgroundColor = mediaClipsEditorViewBackgroundColor
        self.mediaClipsEditorViewButtonLeadingMargin = mediaClipsEditorViewButtonLeadingMargin
        self.mediaClipsEditorViewButtonTrailingMargin = mediaClipsEditorViewButtonTrailingMargin
        self.mediaClipsEditorViewTopPadding = mediaClipsEditorViewTopPadding
        self.mediaClipsEditorViewBottomPadding = mediaClipsEditorViewBottomPadding
        self.mediaClipsEditorViewNextButtonCenterYOffset = mediaClipsEditorViewNextButtonCenterYOffset
        self.mediaClipsEditorViewNextImage = mediaClipsEditorViewNextImage
        self.mediaClipsCollectionCellClipHeight = mediaClipsCollectionCellClipHeight
        self.mediaClipsCollectionCellClipWidth = mediaClipsCollectionCellClipWidth
        self.mediaClipsCollectionCellBorderWidth = mediaClipsCollectionCellBorderWidth
        self.mediaClipsCollectionCellSelectedBorderWidth = mediaClipsCollectionCellSelectedBorderWidth
        self.mediaClipsCollectionCellCornerRadius = mediaClipsCollectionCellCornerRadius
        self.mediaClipsCollectionCellClipAlpha = mediaClipsCollectionCellClipAlpha
        self.mediaClipsCollectionCellFont = mediaClipsCollectionCellFont
        self.mediaClipsCollectionCellLabelVerticalPadding = mediaClipsCollectionCellLabelVerticalPadding
        self.mediaClipsCollectionCellLabelHorizontalPadding = mediaClipsCollectionCellLabelHorizontalPadding
    }
    
    public static var shared: KanvasDesign = {
        return .original
    }()
    
    
    public static var original: KanvasDesign = {
        return KanvasDesign(
            isBottomPicker: false,
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
            shootButtonBorderWidth: 3,
            shootButtonMaximumWidth: 100,
            trashViewOpenedImage: UIImage.imageFromCameraBundle(named: "trashOpened"),
            trashViewClosedImage: UIImage.imageFromCameraBundle(named: "trashClosed"),
            trashViewSize: 98,
            trashViewBorderImageSize: 90,
            trashViewBorderWidth: 3,
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
            filterSettingsViewButtonBackgroundColor: .clear,
            filterSettingsViewButtonBackgroundInvertedColor: .clear,
            filterCollectionInnerCellBorderWidth: 3.0,
            mediaClipsCollectionControllerLeftInset: 11,
            mediaClipsCollectionControllerRightInset: 11,
            mediaClipsCollectionViewFadeOutGradientLocations: [0, 0.05, 0.9, 1.0],
            mediaClipsEditorViewBackgroundColor: KanvasColors.shared.translucentBlack,
            mediaClipsEditorViewButtonLeadingMargin: 16,
            mediaClipsEditorViewButtonTrailingMargin: 16,
            mediaClipsEditorViewTopPadding: 6,
            mediaClipsEditorViewBottomPadding: 6 + (Device.belongsToIPhoneXGroup ? 28 : 0),
            mediaClipsEditorViewNextButtonCenterYOffset: 3,
            mediaClipsEditorViewNextImage: KanvasImages.shared.nextImage,
            mediaClipsCollectionCellClipHeight: 60,
            mediaClipsCollectionCellClipWidth: 40,
            mediaClipsCollectionCellBorderWidth: 1.1,
            mediaClipsCollectionCellSelectedBorderWidth: 2.0,
            mediaClipsCollectionCellCornerRadius: 8,
            mediaClipsCollectionCellClipAlpha: 0.5,
            mediaClipsCollectionCellFont: KanvasFonts.shared.mediaClipsFont,
            mediaClipsCollectionCellLabelVerticalPadding: 3.5,
            mediaClipsCollectionCellLabelHorizontalPadding: 5.5
        )
    }()
    
    
    public static var bottomPicker: KanvasDesign = {
        return KanvasDesign(
            isBottomPicker: true,
            cameraViewButtonBackgroundColor: UIColor.black.withAlphaComponent(0.4),
            cameraViewButtonInvertedBackgroundColor: UIColor.white,
            cameraViewOptionVerticalMargin: 16,
            cameraViewOptionHorizontalMargin: 16,
            cameraViewOptionButtonSize: 48,
            cameraViewOptionSpacing: 16,
            cameraViewNextImage: UIImage.imageFromCameraBundle(named: "nextArrow"),
            cameraViewCloseImage: UIImage.imageFromCameraBundle(named: "cross"),
            shootButtonImageWidth: 25,
            shootButtonInnerCircleImageWidth: 57,
            shootButtonOuterCircleImageWidth: 85,
            shootButtonBorderWidth: 2,
            shootButtonMaximumWidth: 80,
            trashViewOpenedImage: UIImage.imageFromCameraBundle(named: "trashBinOpened"),
            trashViewClosedImage: UIImage.imageFromCameraBundle(named: "trashBinClosed"),
            trashViewSize: 87.1,
            trashViewBorderImageSize: 80,
            trashViewBorderWidth: 2,
            trashViewClosedIconHeight: 28,
            trashViewClosedIconWidth: 24,
            trashViewOpenedIconHeight: 31.76,
            trashViewOpenedIconWidth: 23.29,
            trashViewOpenedIconCenterYOffset: 1,
            trashViewOpenedIconCenterXOffset: 0.9,
            cameraFilterCollectionCellCircleDiameter: 64,
            cameraFilterCollectionCellCircleMaxDiameter: 86,
            cameraOptionFlashOnImage: UIImage.imageFromCameraBundle(named: "cameraFlashOn"),
            cameraOptionFlashOffImage: UIImage.imageFromCameraBundle(named: "cameraFlashOff"),
            cameraOptionGhostFrameOnImage: UIImage.imageFromCameraBundle(named: "ghostFrameOn"),
            cameraOptionGhostFrameOffImage: UIImage.imageFromCameraBundle(named: "ghostFrameOff"),
            cameraOptionCameraPositionImage: UIImage.imageFromCameraBundle(named: "cameraRotate"),
            filterSettingsViewIconSize: 48,
            filterSettingsViewPadding: 0,
            filterSettingsViewFiltersOffImage: UIImage.imageFromCameraBundle(named: "menuFilters"),
            filterSettingsViewFiltersOnImage: UIImage.imageFromCameraBundle(named: "menuFiltersInverted"),
            filterSettingsViewButtonBackgroundColor: .clear,
            filterSettingsViewButtonBackgroundInvertedColor: .white,
            filterCollectionInnerCellBorderWidth: 2.0,
            mediaClipsCollectionControllerLeftInset: 28,
            mediaClipsCollectionControllerRightInset: 14,
            mediaClipsCollectionViewFadeOutGradientLocations: [0, 0.05, 0.95, 1.0],
            mediaClipsEditorViewBackgroundColor: UIColor.black.withAlphaComponent(0.4),
            mediaClipsEditorViewButtonLeadingMargin: 7,
            mediaClipsEditorViewButtonTrailingMargin: 28,
            mediaClipsEditorViewTopPadding: 11,
            mediaClipsEditorViewBottomPadding: Device.belongsToIPhoneXGroup ? 29 : 15,
            mediaClipsEditorViewNextButtonCenterYOffset: 0,
            mediaClipsEditorViewNextImage: UIImage.imageFromCameraBundle(named: "nextArrow"),
            mediaClipsCollectionCellClipHeight: 48,
            mediaClipsCollectionCellClipWidth: 33,
            mediaClipsCollectionCellBorderWidth: 2,
            mediaClipsCollectionCellSelectedBorderWidth: 3,
            mediaClipsCollectionCellCornerRadius: 4,
            mediaClipsCollectionCellClipAlpha: 0.87,
            mediaClipsCollectionCellFont: KanvasFonts.shared.mediaClipsSmallFont,
            mediaClipsCollectionCellLabelVerticalPadding: 4.5,
            mediaClipsCollectionCellLabelHorizontalPadding: 3.5
        )
    }()
}
