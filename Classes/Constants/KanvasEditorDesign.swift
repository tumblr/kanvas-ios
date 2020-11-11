//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

public struct KanvasEditorDesign {
    
    // MARK: - General
    public let isRedesign: Bool
    
    // MARK: - EditorView
    let editorViewCloseImage: UIImage?
    let editorViewBackImage: UIImage?
    let editorViewButtonTopMargin: CGFloat
    let editorViewButtonBottomMargin: CGFloat
    let editorViewFakeOptionCellMinSize: CGFloat
    let editorViewFakeOptionCellMaxSize: CGFloat
    let editorViewCloseButtonSize: CGFloat
    
    public init(isRedesign: Bool,
                editorViewCloseImage: UIImage?,
                editorViewBackImage: UIImage?,
                editorViewButtonTopMargin: CGFloat,
                editorViewButtonBottomMargin: CGFloat,
                editorViewFakeOptionCellMinSize: CGFloat,
                editorViewFakeOptionCellMaxSize: CGFloat,
                editorViewCloseButtonSize: CGFloat) {
        
        self.isRedesign = isRedesign
        self.editorViewCloseImage = editorViewCloseImage
        self.editorViewBackImage = editorViewBackImage
        self.editorViewButtonTopMargin = editorViewButtonTopMargin
        self.editorViewButtonBottomMargin = editorViewButtonBottomMargin
        self.editorViewFakeOptionCellMinSize = editorViewFakeOptionCellMinSize
        self.editorViewFakeOptionCellMaxSize = editorViewFakeOptionCellMaxSize
        self.editorViewCloseButtonSize = editorViewCloseButtonSize
    }
    
    public static var shared: KanvasEditorDesign = {
        return .defaultDesign
    }()
    
    
    public static var defaultDesign: KanvasEditorDesign = {
        return KanvasEditorDesign(
            isRedesign: false,
            editorViewCloseImage: UIImage.imageFromCameraBundle(named: "whiteCloseIcon"),
            editorViewBackImage: UIImage.imageFromCameraBundle(named: "back"),
            editorViewButtonTopMargin: 24,
            editorViewButtonBottomMargin: Device.belongsToIPhoneXGroup ? 14 : 19.5,
            editorViewFakeOptionCellMinSize: 36,
            editorViewFakeOptionCellMaxSize: 45,
            editorViewCloseButtonSize: 26.5
        )
    }()
    
    
    public static var redesign: KanvasEditorDesign = {
        return KanvasEditorDesign(
            isRedesign: true,
            editorViewCloseImage: UIImage.imageFromCameraBundle(named: "cross"),
            editorViewBackImage: UIImage.imageFromCameraBundle(named: "backArrow"),
            editorViewButtonTopMargin: 28,
            editorViewButtonBottomMargin: Device.belongsToIPhoneXGroup ? 14 : 19.5,
            editorViewFakeOptionCellMinSize: 48,
            editorViewFakeOptionCellMaxSize: 48,
            editorViewCloseButtonSize: 48
        )
    }()
}
