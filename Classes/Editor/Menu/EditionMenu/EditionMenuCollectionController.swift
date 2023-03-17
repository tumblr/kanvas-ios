//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for Collection Controller
private struct Constants {
    static let section: Int = 0
    static let animationDuration: TimeInterval = 0.25
    static let collectionLeftInset: CGFloat = 12
    static let collectionRightInset: CGFloat = 20
}

/// Controller for handling the filter item collection.
final class EditionMenuCollectionController: UIViewController, KanvasEditorMenuController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EditionMenuCollectionCellDelegate {
    
    private lazy var editionMenuCollectionView = EditionMenuCollectionView()
    private var editionOptions: [EditionOption]
    weak var delegate: KanvasEditorMenuControllerDelegate?
    
    var shouldExportMediaAsGIF: Bool {
        didSet {
            guard let index = editionOptions.firstIndex(of: .gif) else { return }
            editionMenuCollectionView.collectionView.reloadItems(at: [IndexPath(item: index, section: Constants.section)])
        }
    }
    
    /// Initializes the option collection
    /// - Parameter settings: Camera settings
    /// - Parameter shouldExportMediaAsGIF: initial value for GIF export toggle button. `nil` means the button is disabled.
    init(settings: CameraSettings, shouldExportMediaAsGIF: Bool?) {
        self.editionOptions = []
        self.shouldExportMediaAsGIF = shouldExportMediaAsGIF ?? false

        if settings.features.gifs && shouldExportMediaAsGIF != nil {
            editionOptions.append(.gif)
        }
        
        if settings.features.editorFilters {
            editionOptions.append(.filter)
        }
        
        if settings.features.editorCropRotate {
            editionOptions.append(.cropRotate)
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
    
    // MARK: - View Life Cycle
    
    override func loadView() {
        view = editionMenuCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editionMenuCollectionView.collectionView.register(cell: EditionMenuCollectionCell.self)
        editionMenuCollectionView.collectionView.delegate = self
        editionMenuCollectionView.collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editionMenuCollectionView.updateFadeOutEffect()
        editionMenuCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        editionMenuCollectionView.collectionView.layoutIfNeeded()
    }
    
    // MARK: - KanvasEditorMenuController
    
    /// shows or hides the edition menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.editionMenuCollectionView.alpha = show ? 1 : 0
        }
    }
    
    func getCell(for option: EditionOption) -> KanvasEditorMenuCollectionCell? {
        guard
            let collectionView = (view as? EditionMenuCollectionView)?.collectionView,
            let index = editionOptions.firstIndex(of: option)
        else {
            return nil
        }
        let indexPath = IndexPath(item: index, section: Constants.section)
        return self.collectionView(collectionView, cellForItemAt: indexPath) as? EditionMenuCollectionCell
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editionOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditionMenuCollectionCell.identifier, for: indexPath)
        if let cell = cell as? EditionMenuCollectionCell, let option = editionOptions.object(at: indexPath.item) {
            cell.bindTo(option, enabled: option == .gif ? shouldExportMediaAsGIF : false)
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard editionOptions.count > 0, collectionView.bounds != .zero else { return .zero }
        return UIEdgeInsets(top: 0, left: Constants.collectionLeftInset, bottom: 0, right: Constants.collectionRightInset)
    }
    
    // MARK: - Option selection
    
    /// Selects an option
    ///
    /// - Parameter index: position of the option in the collection
    /// - Parameter cell: the selected cell
    private func selectEditionOption(index: Int, cell: EditionMenuCollectionCell) {
        guard let option = editionOptions.object(at: index) else { return }
        delegate?.didSelectEditionOption(option, cell: cell)
    }
    
    // MARK: - EditionMenuCollectionCellDelegate
    
    func didTap(cell: EditionMenuCollectionCell, recognizer: UITapGestureRecognizer) {
        if let indexPath = editionMenuCollectionView.collectionView.indexPath(for: cell) {
            selectEditionOption(index: indexPath.item, cell: cell)
        }
    }
}
