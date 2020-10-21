//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for Collection Controller
private struct StyleMenuCollectionControllerConstants {
    static let section: Int = 0
    static let animationDuration: TimeInterval = 0.25
}

/// Controller for handling the filter item collection.
final class StyleMenuCollectionController: UIViewController, KanvasEditionMenuController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StyleMenuCollectionCellDelegate {
    
    private lazy var styleMenuCollectionView = StyleMenuCollectionView()
    private var editionOptions: [EditionOption]
    
    var shouldExportMediaAsGIF: Bool {
        didSet {
            guard let index = editionOptions.firstIndex(of: .gif) else { return }
            styleMenuCollectionView.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    weak var delegate: KanvasEditionMenuControllerDelegate?
    
    /// Initializes the option collection
    /// - Parameter settings: Camera settings
    /// - Parameter shouldExportMediaAsGIF: initial value for GIF export toggle button. `nil` means the button is disabled.
    init(settings: CameraSettings, shouldExportMediaAsGIF: Bool?) {
        editionOptions = []
        self.shouldExportMediaAsGIF = shouldExportMediaAsGIF ?? false

        if settings.features.gifs && shouldExportMediaAsGIF != nil {
            editionOptions.append(.gif)
        }
        
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

    func getCell(for option: EditionOption) -> KanvasEditionMenuCollectionCell? {
        guard
            let collectionView = (view as? StyleMenuCollectionView)?.collectionView,
            let index = editionOptions.firstIndex(of: option)
        else {
            return nil
        }
        let indexPath = IndexPath(item: index, section: 0)
        return self.collectionView(collectionView, cellForItemAt: indexPath) as? StyleMenuCollectionCell
    }
    
    // MARK: - View Life Cycle
    
    override func loadView() {
        view = styleMenuCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleMenuCollectionView.collectionView.register(cell: StyleMenuCollectionCell.self)
        styleMenuCollectionView.collectionView.delegate = self
        styleMenuCollectionView.collectionView.dataSource = self
    }
    
    // MARK: - Public interface
    
    /// shows or hides the style menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: StyleMenuCollectionControllerConstants.animationDuration) {
            self.styleMenuCollectionView.alpha = show ? 1 : 0
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editionOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StyleMenuCollectionCell.identifier, for: indexPath)
        if let cell = cell as? StyleMenuCollectionCell, let option = editionOptions.object(at: indexPath.item) {
            cell.bindTo(option, enabled: option == .gif ? shouldExportMediaAsGIF : false)
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemCount = CGFloat(editionOptions.count)
        let totalCellHeight = StyleMenuCollectionCell.height * itemCount

        let inset = (collectionView.frame.height - totalCellHeight) / 2

        return UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
    }
    
    // MARK: Option selection
    
    /// Selects an option
    ///
    /// - Parameter index: position of the option in the collection
    /// - Parameter cell: the selected cell
    private func selectEditionOption(index: Int, cell: StyleMenuCollectionCell) {
        guard let option = editionOptions.object(at: index) else { return }
        delegate?.didSelectEditionOption(option, cell: cell)
    }
    
    // MARK: - StyleMenuCollectionCellDelegate
    
    func didTap(cell: StyleMenuCollectionCell, recognizer: UITapGestureRecognizer) {
        if let indexPath = styleMenuCollectionView.collectionView.indexPath(for: cell) {
            selectEditionOption(index: indexPath.item, cell: cell)
        }
    }
}
