//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

public struct KanvasEditorDesign {
    
    // MARK: - General
    public let isVerticalMenu: Bool
    
    // MARK: - Menu
    let checkmarkImage: UIImage?
    let buttonBackgroundColor: UIColor
    let buttonInvertedBackgroundColor: UIColor
    let optionBackgroundColor: UIColor
    let topButtonSize: CGFloat
    let topSecondaryButtonSize: CGFloat
    let topButtonInterspace: CGFloat
    let fakeOptionCellCheckmarkImage: UIImage?
    let closeGradientImage: UIImage?
    
    // MARK: - EditorView
    let editorViewCloseImage: UIImage?
    let editorViewBackImage: UIImage?
    let editorViewButtonTopMargin: CGFloat
    let editorViewButtonBottomMargin: CGFloat
    let editorViewFakeOptionCellMinSize: CGFloat
    let editorViewFakeOptionCellMaxSize: CGFloat
    let editorViewCloseButtonSize: CGFloat
    let editorViewCloseButtonHorizontalMargin: CGFloat
    
    // MARK: - DrawingView
    let drawingViewUndoImage: UIImage?
    let drawingViewEraserSelectedImage: UIImage?
    let drawingViewEraserUnselectedImage: UIImage?
    let drawingViewMarkerImage: UIImage?
    let drawingViewSharpieImage: UIImage?
    let drawingViewPencilImage: UIImage?
    let drawingViewEyeDropperImage: UIImage?
    
    // MARK: - EditorTextView
    let editorTextViewFontImage: UIImage?
    let editorTextViewAlignmentImage: [NSTextAlignment: UIImage?]
    let editorTextViewHighlightImage: (Bool) -> UIImage?
    
    public init(isVerticalMenu: Bool,
                checkmarkImage: UIImage?,
                buttonBackgroundColor: UIColor,
                buttonInvertedBackgroundColor: UIColor,
                optionBackgroundColor: UIColor,
                topButtonSize: CGFloat,
                topSecondaryButtonSize: CGFloat,
                topButtonInterspace: CGFloat,
                fakeOptionCellCheckmarkImage: UIImage?,
                closeGradientImage: UIImage?,
                editorViewCloseImage: UIImage?,
                editorViewBackImage: UIImage?,
                editorViewButtonTopMargin: CGFloat,
                editorViewButtonBottomMargin: CGFloat,
                editorViewFakeOptionCellMinSize: CGFloat,
                editorViewFakeOptionCellMaxSize: CGFloat,
                editorViewCloseButtonSize: CGFloat,
                editorViewCloseButtonHorizontalMargin: CGFloat,
                drawingViewUndoImage: UIImage?,
                drawingViewEraserSelectedImage: UIImage?,
                drawingViewEraserUnselectedImage: UIImage?,
                drawingViewMarkerImage: UIImage?,
                drawingViewSharpieImage: UIImage?,
                drawingViewPencilImage: UIImage?,
                drawingViewEyeDropperImage: UIImage?,
                editorTextViewFontImage: UIImage?,
                editorTextViewAlignmentImage: [NSTextAlignment: UIImage?],
                editorTextViewHighlightImage: @escaping (Bool) -> UIImage?) {
        
        self.isVerticalMenu = isVerticalMenu
        self.checkmarkImage = checkmarkImage
        self.buttonBackgroundColor = buttonBackgroundColor
        self.buttonInvertedBackgroundColor = buttonInvertedBackgroundColor
        self.optionBackgroundColor = optionBackgroundColor
        self.topButtonSize = topButtonSize
        self.topSecondaryButtonSize = topSecondaryButtonSize
        self.topButtonInterspace = topButtonInterspace
        self.fakeOptionCellCheckmarkImage = fakeOptionCellCheckmarkImage
        self.closeGradientImage = closeGradientImage
        self.editorViewCloseImage = editorViewCloseImage
        self.editorViewBackImage = editorViewBackImage
        self.editorViewButtonTopMargin = editorViewButtonTopMargin
        self.editorViewButtonBottomMargin = editorViewButtonBottomMargin
        self.editorViewFakeOptionCellMinSize = editorViewFakeOptionCellMinSize
        self.editorViewFakeOptionCellMaxSize = editorViewFakeOptionCellMaxSize
        self.editorViewCloseButtonSize = editorViewCloseButtonSize
        self.editorViewCloseButtonHorizontalMargin = editorViewCloseButtonHorizontalMargin
        self.drawingViewUndoImage = drawingViewUndoImage
        self.drawingViewEraserSelectedImage = drawingViewEraserSelectedImage
        self.drawingViewEraserUnselectedImage = drawingViewEraserUnselectedImage
        self.drawingViewMarkerImage = drawingViewMarkerImage
        self.drawingViewSharpieImage = drawingViewSharpieImage
        self.drawingViewPencilImage = drawingViewPencilImage
        self.drawingViewEyeDropperImage = drawingViewEyeDropperImage
        self.editorTextViewFontImage = editorTextViewFontImage
        self.editorTextViewAlignmentImage = editorTextViewAlignmentImage
        self.editorTextViewHighlightImage = editorTextViewHighlightImage
    }
    
    public static var shared: KanvasEditorDesign = {
        return .original
    }()
    
    
    public static var original: KanvasEditorDesign = {
        return KanvasEditorDesign(
            isVerticalMenu: false,
            checkmarkImage: KanvasImages.shared.editorConfirmImage,
            buttonBackgroundColor: .clear,
            buttonInvertedBackgroundColor: .clear,
            optionBackgroundColor: .clear,
            topButtonSize: 36,
            topSecondaryButtonSize: 36,
            topButtonInterspace: 30,
            fakeOptionCellCheckmarkImage: UIImage.imageFromCameraBundle(named: "confirm"),
            closeGradientImage: UIImage.imageFromCameraBundle(named: "closeGradient"),
            editorViewCloseImage: UIImage.imageFromCameraBundle(named: "whiteCloseIcon"),
            editorViewBackImage: UIImage.imageFromCameraBundle(named: "back"),
            editorViewButtonTopMargin: 24,
            editorViewButtonBottomMargin: Device.belongsToIPhoneXGroup ? 14 : 19.5,
            editorViewFakeOptionCellMinSize: 36,
            editorViewFakeOptionCellMaxSize: 45,
            editorViewCloseButtonSize: 26.5,
            editorViewCloseButtonHorizontalMargin: 24,
            drawingViewUndoImage: UIImage.imageFromCameraBundle(named: "undo"),
            drawingViewEraserSelectedImage: UIImage.imageFromCameraBundle(named: "eraserSelected"),
            drawingViewEraserUnselectedImage: UIImage.imageFromCameraBundle(named: "eraserUnselected"),
            drawingViewMarkerImage: UIImage.imageFromCameraBundle(named: "marker"),
            drawingViewSharpieImage: UIImage.imageFromCameraBundle(named: "sharpie"),
            drawingViewPencilImage: UIImage.imageFromCameraBundle(named: "pencil"),
            drawingViewEyeDropperImage: UIImage.imageFromCameraBundle(named: "eyeDropper"),
            editorTextViewFontImage: UIImage.imageFromCameraBundle(named: "font"),
            editorTextViewAlignmentImage: [
                .left: UIImage.imageFromCameraBundle(named: "leftAlignment"),
                .center: UIImage.imageFromCameraBundle(named: "centerAlignment"),
                .right: UIImage.imageFromCameraBundle(named: "rightAlignment"),
            ],
            editorTextViewHighlightImage: { selected in
                return selected ? UIImage.imageFromCameraBundle(named: "highlightSelected") : UIImage.imageFromCameraBundle(named: "highlightUnselected")
            }
        )
    }()
    
    
    public static var verticalMenu: KanvasEditorDesign = {
        return KanvasEditorDesign(
            isVerticalMenu: true,
            checkmarkImage: UIImage.imageFromCameraBundle(named: "longCheckmark"),
            buttonBackgroundColor: UIColor.black.withAlphaComponent(0.4),
            buttonInvertedBackgroundColor: .white,
            optionBackgroundColor: .white,
            topButtonSize: 48,
            topSecondaryButtonSize: 36,
            topButtonInterspace: 16,
            fakeOptionCellCheckmarkImage: UIImage.imageFromCameraBundle(named: "longCheckmark"),
            closeGradientImage: UIImage.imageFromCameraBundle(named: "closeGradientRounded"),
            editorViewCloseImage: UIImage.imageFromCameraBundle(named: "cross"),
            editorViewBackImage: UIImage.imageFromCameraBundle(named: "backArrow"),
            editorViewButtonTopMargin: 16,
            editorViewButtonBottomMargin: Device.belongsToIPhoneXGroup ? 14 : 19.5,
            editorViewFakeOptionCellMinSize: 48,
            editorViewFakeOptionCellMaxSize: 48,
            editorViewCloseButtonSize: 48,
            editorViewCloseButtonHorizontalMargin: 16,
            drawingViewUndoImage: UIImage.imageFromCameraBundle(named: "undoLong"),
            drawingViewEraserSelectedImage: UIImage.imageFromCameraBundle(named: "eraserOn"),
            drawingViewEraserUnselectedImage: UIImage.imageFromCameraBundle(named: "eraserOff"),
            drawingViewMarkerImage: UIImage.imageFromCameraBundle(named: "markerRounded"),
            drawingViewSharpieImage: UIImage.imageFromCameraBundle(named: "sharpieRounded"),
            drawingViewPencilImage: UIImage.imageFromCameraBundle(named: "pencilRounded"),
            drawingViewEyeDropperImage: UIImage.imageFromCameraBundle(named: "eyeDropperRounded"),
            editorTextViewFontImage: UIImage.imageFromCameraBundle(named: "fontBlock"),
            editorTextViewAlignmentImage: [
                .left: UIImage.imageFromCameraBundle(named: "leftAlignmentRounded"),
                .center: UIImage.imageFromCameraBundle(named: "centerAlignmentRounded"),
                .right: UIImage.imageFromCameraBundle(named: "rightAlignmentRounded"),
            ],
            editorTextViewHighlightImage: { selected in
                return selected ? UIImage.imageFromCameraBundle(named: "highlightSelectedRounded") : UIImage.imageFromCameraBundle(named: "highlightUnselectedRounded")
            }
        )
    }()

    public static var storiesDesign: KanvasEditorDesign = {
        return KanvasEditorDesign(
            isVerticalMenu: false,
            checkmarkImage: KanvasImages.shared.editorConfirmImage,
            buttonBackgroundColor: .clear,
            buttonInvertedBackgroundColor: .clear,
            optionBackgroundColor: .clear,
            topButtonSize: 49,
            topSecondaryButtonSize: 36,
            topButtonInterspace: 30,
            fakeOptionCellCheckmarkImage: UIImage.imageFromCameraBundle(named: "confirm"),
            closeGradientImage: UIImage.imageFromCameraBundle(named: "closeGradient"),
            editorViewCloseImage: UIImage.imageFromCameraBundle(named: "whiteCloseIcon"),
            editorViewBackImage: UIImage.imageFromCameraBundle(named: "back"),
            editorViewButtonTopMargin: 24,
            editorViewButtonBottomMargin: Device.belongsToIPhoneXGroup ? 14 : 19.5,
            editorViewFakeOptionCellMinSize: 36,
            editorViewFakeOptionCellMaxSize: 45,
            editorViewCloseButtonSize: 26.5,
            editorViewCloseButtonHorizontalMargin: 24,
            drawingViewUndoImage: UIImage.imageFromCameraBundle(named: "undo"),
            drawingViewEraserSelectedImage: UIImage.imageFromCameraBundle(named: "eraserSelected"),
            drawingViewEraserUnselectedImage: UIImage.imageFromCameraBundle(named: "eraserUnselected"),
            drawingViewMarkerImage: UIImage.imageFromCameraBundle(named: "marker"),
            drawingViewSharpieImage: UIImage.imageFromCameraBundle(named: "sharpie"),
            drawingViewPencilImage: UIImage.imageFromCameraBundle(named: "pencil"),
            drawingViewEyeDropperImage: UIImage.imageFromCameraBundle(named: "eyeDropper"),
            editorTextViewFontImage: UIImage.imageFromCameraBundle(named: "font"),
            editorTextViewAlignmentImage: [
                .left: UIImage.imageFromCameraBundle(named: "leftAlignment"),
                .center: UIImage.imageFromCameraBundle(named: "centerAlignment"),
                .right: UIImage.imageFromCameraBundle(named: "rightAlignment"),
            ],
            editorTextViewHighlightImage: { selected in
                return selected ? UIImage.imageFromCameraBundle(named: "highlightSelected") : UIImage.imageFromCameraBundle(named: "highlightUnselected")
            }
        )
    }()
}
