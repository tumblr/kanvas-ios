//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for the texture selector
private struct TextureSelectorControllerConstants {
    static let animationDuration: TimeInterval = 0.25
}

/// Controller for handling the texture selector on the drawing menu.
final class TextureSelectorController: UIViewController, TextureSelectorViewDelegate {
    
    private lazy var textureSelectorView: TextureSelectorView = {
        let view = TextureSelectorView()
        view.delegate = self
        return view
    }()
    
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
    
    // MARK: - View Life Cycle
    
    override func loadView() {
        view = textureSelectorView
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
        textureSelectorView.changeMainButtonIcon(image: KanvasCameraImages.pencilImage)
        textureSelectorView.showSelectorBackground(false)
    }
    
    func didTapSharpieButton() {
        textureSelectorView.changeMainButtonIcon(image: KanvasCameraImages.sharpieImage)
        textureSelectorView.showSelectorBackground(false)
    }
    
    func didTapMarkerButton() {
        textureSelectorView.changeMainButtonIcon(image: KanvasCameraImages.markerImage)
        textureSelectorView.showSelectorBackground(false)
    }
    
}
