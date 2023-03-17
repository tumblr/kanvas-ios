//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for the controller.
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
}

/// Controller that handles the option collection.
final class StyleMenuController: UIViewController, KanvasEditorMenuController, StyleMenuViewDelegate {
        
    private var editionOptions: [EditionOption]
    weak var delegate: KanvasEditorMenuControllerDelegate?
    
    private lazy var styleMenuView: StyleMenuView = {
        return StyleMenuView(delegate: self)
    }()
    
    var shouldExportMediaAsGIF: Bool {
        didSet {
            guard let index = editionOptions.firstIndex(of: .gif) else { return }
            styleMenuView.reloadItem(at: index)
        }
    }
    
    // MARK: - Initializers
    
    /// Initializes the option collection.
    ///
    /// - Parameters
    ///   - settings: the camera settings.
    ///   - shouldExportMediaAsGIF: initial value for GIF export toggle button. `nil` means the button is disabled.
    init(settings: CameraSettings, shouldExportMediaAsGIF: Bool?) {
        self.editionOptions = []
        self.shouldExportMediaAsGIF = shouldExportMediaAsGIF ?? false
        
        if settings.features.editorFilters {
            editionOptions.append(.filter)
        }
        
        if settings.features.editorText {
            editionOptions.append(.text)
        }
        
        if settings.features.editorMedia {
            editionOptions.append(.media)
        }
        
        if settings.features.editorDrawing {
            editionOptions.append(.drawing)
        }
        
        if settings.features.gifs && shouldExportMediaAsGIF != nil {
            editionOptions.append(.gif)
        }
        
        if settings.features.editorCropRotate {
            editionOptions.append(.cropRotate)
        }
        
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
        view = styleMenuView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleMenuView.load()
        styleMenuView.showTemporalLabels()
    }
    
    // MARK: - KanvasEditorMenuController
    
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.styleMenuView.alpha = show ? 1 : 0
        }
    }
    
    func getCell(for option: EditionOption) -> KanvasEditorMenuCollectionCell? {
        guard let index = editionOptions.firstIndex(of: option) else { return nil }
        return styleMenuView.getCell(at: index)
    }
    
    // MARK: - StyleMenuViewDelegate
    
    func numberOfItems() -> Int {
        return editionOptions.count
    }
    
    func bindItem(at index: Int, cell: StyleMenuCell) {
        guard let option = editionOptions.object(at: index) else { return }
        cell.bindTo(option, enabled: option == .gif ? shouldExportMediaAsGIF : false)
    }
    
    func didSelect(cell: StyleMenuCell) {
        guard let index = styleMenuView.getIndex(for: cell) else { return }
        selectEditionOption(index: index, cell: cell)
    }
    
    // MARK: - Option selection
    
    /// Selects an option.
    ///
    /// - Parameters
    ///   - index: position of the option in the collection.
    ///   - cell: the selected cell.
    private func selectEditionOption(index: Int, cell: StyleMenuCell) {
        guard let option = editionOptions.object(at: index) else { return }
        delegate?.didSelectEditionOption(option, cell: cell)
        styleMenuView.collapseCollection(animated: true)
    }
}
