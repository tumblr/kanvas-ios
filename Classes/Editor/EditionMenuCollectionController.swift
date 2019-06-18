//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol EditionMenuCollectionControllerDelegate: class {
    /// Callback for the selection of an option
    ///
    /// - Parameter editionOption: the selected option
    func didSelectEditionOption(_ editionOption: EditionOption)
}

/// Constants for Collection Controller
private struct EditionMenuCollectionControllerConstants {
    static let section: Int = 0
    static let animationDuration: TimeInterval = 0.25
    static let collectionLeftInset: CGFloat = 12
    static let collectionRightInset: CGFloat = 20
}

/// Controller for handling the filter item collection.
final class EditionMenuCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EditionMenuCollectionCellDelegate {
    
    private lazy var editionMenuCollectionView = EditionMenuCollectionView()
    private var editionOptions: [EditionOption]
    
    weak var delegate: EditionMenuCollectionControllerDelegate?
    
    /// Initializes the option collection
    init(settings: CameraSettings) {
        editionOptions = []
        
        if settings.features.editorFilters {
            editionOptions.append(EditionOption(type: .filter))
        }
        
        if settings.features.editorMedia {
            editionOptions.append(EditionOption(type: .media))
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
    
    // MARK: - Public interface
    
    /// shows or hides the edition menu
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: EditionMenuCollectionControllerConstants.animationDuration) {
            self.editionMenuCollectionView.alpha = show ? 1 : 0
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditionMenuCollectionCell.identifier, for: indexPath)
        if let cell = cell as? EditionMenuCollectionCell, let option = editionOptions.object(at: indexPath.item) {
            cell.bindTo(option)
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard editionOptions.count > 0, collectionView.bounds != .zero else { return .zero }
        return UIEdgeInsets(top: 0, left: EditionMenuCollectionControllerConstants.collectionLeftInset, bottom: 0, right: EditionMenuCollectionControllerConstants.collectionRightInset)
    }
    
    // MARK: Option selection
    
    /// Selects an option
    ///
    /// - Parameter index: position of the option in the collection
    private func selectEditionOption(index: Int) {
        guard let option = editionOptions.object(at: index) else { return }
        delegate?.didSelectEditionOption(option)
    }
    
    // MARK: - EditionMenuCollectionCellDelegate
    
    func didTap(cell: EditionMenuCollectionCell, recognizer: UITapGestureRecognizer) {
        if let indexPath = editionMenuCollectionView.collectionView.indexPath(for: cell) {
            selectEditionOption(index: indexPath.item)
        }
    }
}

/// Returns the object located at the specified index.
/// If the index is beyond the end of the array, nil is returned.
///
/// - Parameter index: an index within the bounds of the array
private extension Array {
    func object(at index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}
