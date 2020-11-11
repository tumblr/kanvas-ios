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
    
    public init(isRedesign: Bool,
                editorViewCloseImage: UIImage?,
                editorViewBackImage: UIImage?) {
        
        self.isRedesign = isRedesign
        self.editorViewCloseImage = editorViewCloseImage
        self.editorViewBackImage = editorViewBackImage
    }
    
    public static var shared: KanvasEditorDesign = {
        return .defaultDesign
    }()
    
    
    public static var defaultDesign: KanvasEditorDesign = {
        return KanvasEditorDesign(
            isRedesign: false,
            editorViewCloseImage: UIImage.imageFromCameraBundle(named: "whiteCloseIcon"),
            editorViewBackImage: UIImage.imageFromCameraBundle(named: "back")
        )
    }()
    
    
    public static var redesign: KanvasEditorDesign = {
        return KanvasEditorDesign(
            isRedesign: true,
            editorViewCloseImage: UIImage.imageFromCameraBundle(named: "cross"),
            editorViewBackImage: UIImage.imageFromCameraBundle(named: "backArrow")
        )
    }()
}
