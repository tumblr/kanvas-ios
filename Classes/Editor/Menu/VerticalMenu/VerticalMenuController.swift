//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for the controller
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
}

/// Controller for handling the filter item collection.
final class VerticalMenuController: UIViewController, KanvasEditorMenuController, VerticalMenuViewDelegate, VerticalMenuCellDelegate {
        
    private var editionOptions: [EditionOption]
    weak var delegate: KanvasEditorMenuControllerDelegate?
    
    private lazy var verticalMenuView: VerticalMenuView = {
        return VerticalMenuView(delegate: self)
    }()
    
    var shouldExportMediaAsGIF: Bool {
        didSet {
            guard let index = editionOptions.firstIndex(of: .gif) else { return }
            verticalMenuView.reloadItem(at: index)
        }
    }
    
    /// Initializes the option collection
    /// - Parameter settings: Camera settings
    /// - Parameter shouldExportMediaAsGIF: initial value for GIF export toggle button. `nil` means the button is disabled.
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
        view = verticalMenuView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verticalMenuView.reload()
    }
    
    // MARK: - KanvasEditorMenuController
    
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.verticalMenuView.alpha = show ? 1 : 0
        }
    }
    
    func getCell(for option: EditionOption) -> KanvasEditorMenuCollectionCell? {
        guard let index = editionOptions.firstIndex(of: option) else { return nil }
        return verticalMenuView.getCell(at: index)
    }
    
    // MARK: - VerticalMenuViewDelegate
    
    func numberOfItems() -> Int {
        return editionOptions.count
    }
    
    func bindItem(at index: Int) {
        guard let option = editionOptions.object(at: index), let cell = verticalMenuView.getCell(at: index) else { return }
        cell.bindTo(option, enabled: option == .gif ? shouldExportMediaAsGIF : false)
        cell.delegate = self
    }
    
    // MARK: - Option selection
    
    /// Selects an option
    ///
    /// - Parameter index: position of the option in the collection
    /// - Parameter cell: the selected cell
    private func selectEditionOption(index: Int, cell: VerticalMenuCell) {
        guard let option = editionOptions.object(at: index) else { return }
        delegate?.didSelectEditionOption(option, cell: cell)
    }
    
    // MARK: - VerticalMenuCellDelegate
    
    func didTap(cell: VerticalMenuCell, recognizer: UITapGestureRecognizer) {
        guard let index = verticalMenuView.getIndex(for: cell) else { return }
        selectEditionOption(index: index, cell: cell)
    }
}
