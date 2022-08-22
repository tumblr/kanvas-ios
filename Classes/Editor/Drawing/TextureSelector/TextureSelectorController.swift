//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol TextureSelectorControllerDelegate: AnyObject {
    func didSelectTexture(textureType: KanvasBrushType)
}

/// Constants for the texture selector
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
}

/// Controller for handling the texture selector on the drawing menu.
final class TextureSelectorController: UIViewController, TextureSelectorViewDelegate {
    
    private(set) var texture: Texture = Sharpie()
    
    private lazy var textureSelectorView: TextureSelectorView = {
        let view = TextureSelectorView()
        view.delegate = self
        return view
    }()

    weak var delegate: TextureSelectorControllerDelegate?
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: .none, bundle: .none)
    }
    
    @available(*, unavailable, message: "use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init() instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        view = textureSelectorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentTexture(texture.textureType)
    }
    
    // MARK: - Private utilities
    
    private func setCurrentTexture(_ textureType: KanvasBrushType) {
        let newTexture: Texture
        let newImage: UIImage?
        
        switch textureType {
        case .pencil:
            newTexture = Pencil()
            newImage = KanvasEditorDesign.shared.drawingViewPencilImage
        case .marker:
            newTexture = Marker()
            newImage = KanvasEditorDesign.shared.drawingViewMarkerImage
        case .sharpie:
            newTexture = Sharpie()
            newImage = KanvasEditorDesign.shared.drawingViewSharpieImage
        }
        
        textureSelectorView.changeMainButtonIcon(image: newImage)
        textureSelectorView.arrangeOptions(selectedOption: textureType)
        texture = newTexture
        
        textureSelectorView.showSelectorBackground(false)
    }
    
    // MARK: - Public interface
    
    /// Shows or hides the texture selector
    ///
    /// - Parameter show: true to show, false to hide
    func showSelector(_ show: Bool) {
        textureSelectorView.showSelectorBackground(show)
    }
    
    // MARK: - TextureSelectorViewDelegate
    
    func didTapTextureButton() {
        textureSelectorView.showSelectorBackground(true)
    }
    
    func didTapPencilButton() {
        setCurrentTexture(.pencil)
        delegate?.didSelectTexture(textureType: .pencil)
    }
    
    func didTapSharpieButton() {
        setCurrentTexture(.sharpie)
        delegate?.didSelectTexture(textureType: .sharpie)
    }
    
    func didTapMarkerButton() {
        setCurrentTexture(.marker)
        delegate?.didSelectTexture(textureType: .marker)
    }
}
