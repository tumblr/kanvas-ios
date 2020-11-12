//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

public struct KanvasEditorDesign {
    
    // MARK: - General
    public let isRedesign: Bool
    
    // MARK: - Menu
    let checkmarkImage: UIImage?
    let buttonBackgroundColor: UIColor
    let buttonInvertedBackgroundColor: UIColor
    let topButtonSize: CGFloat
    let topSecondaryButtonSize: CGFloat
    let topButtonInterspace: CGFloat
    let fakeOptionCellCheckmarkImage: UIImage?
    
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
    
    public init(isRedesign: Bool,
                checkmarkImage: UIImage?,
                buttonBackgroundColor: UIColor,
                buttonInvertedBackgroundColor: UIColor,
                topButtonSize: CGFloat,
                topSecondaryButtonSize: CGFloat,
                topButtonInterspace: CGFloat,
                fakeOptionCellCheckmarkImage: UIImage?,
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
                drawingViewEraserUnselectedImage: UIImage?) {
        
        self.isRedesign = isRedesign
        self.checkmarkImage = checkmarkImage
        self.buttonBackgroundColor = buttonBackgroundColor
        self.buttonInvertedBackgroundColor = buttonInvertedBackgroundColor
        self.topButtonSize = topButtonSize
        self.topSecondaryButtonSize = topSecondaryButtonSize
        self.topButtonInterspace = topButtonInterspace
        self.fakeOptionCellCheckmarkImage = fakeOptionCellCheckmarkImage
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
    }
    
    public static var shared: KanvasEditorDesign = {
        return .defaultDesign
    }()
    
    
    public static var defaultDesign: KanvasEditorDesign = {
        return KanvasEditorDesign(
            isRedesign: false,
            checkmarkImage: UIImage.imageFromCameraBundle(named: "editorConfirm"),
            buttonBackgroundColor: .clear,
            buttonInvertedBackgroundColor: .clear,
            topButtonSize: 36,
            topSecondaryButtonSize: 36,
            topButtonInterspace: 30,
            fakeOptionCellCheckmarkImage: UIImage.imageFromCameraBundle(named: "confirm"),
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
            drawingViewEraserUnselectedImage: UIImage.imageFromCameraBundle(named: "eraserUnselected")
        )
    }()
    
    
    public static var redesign: KanvasEditorDesign = {
        return KanvasEditorDesign(
            isRedesign: true,
            checkmarkImage: UIImage.imageFromCameraBundle(named: "longCheckmark"),
            buttonBackgroundColor: UIColor.black.withAlphaComponent(0.4),
            buttonInvertedBackgroundColor: .white,
            topButtonSize: 48,
            topSecondaryButtonSize: 36,
            topButtonInterspace: 16,
            fakeOptionCellCheckmarkImage: UIImage.imageFromCameraBundle(named: "longCheckmark"),
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
            drawingViewEraserUnselectedImage: UIImage.imageFromCameraBundle(named: "eraserOff")
        )
    }()
}
