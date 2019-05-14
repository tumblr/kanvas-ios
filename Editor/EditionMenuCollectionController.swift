//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol EditionMenuCollectionControllerDelegate: class {
    /// Callback for when a filter item is selected
    ///
    /// - Parameter filterItem: the selected filter
    func didSelectEditionOption(_ editionOption: EditionOption)
}

/// Constants for Collection Controller
private struct EditionMenuCollectionControllerConstants {
    static let horizontalInset: CGFloat = 20
    static let animationDuration: TimeInterval = 0.25
    static let initialCell: Int = 0
    static let section: Int = 0
}

/// Controller for handling the filter item collection.
final class EditionMenuCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    private lazy var editionMenuCollectionView = EditionMenuCollectionView()
    private var editionOptions: [EditionOption]
    private var selectedIndexPath: IndexPath
    
    weak var delegate: EditionMenuCollectionControllerDelegate?
    
    /// Initializes the collection
    init(settings: CameraSettings) {
        editionOptions = [
            EditionOption(image: KanvasCameraImages.editorFilters),
            EditionOption(image: KanvasCameraImages.editorGif),
            EditionOption(image: KanvasCameraImages.editorMedia),
        ]

        selectedIndexPath = IndexPath(item: EditionMenuCollectionControllerConstants.initialCell, section: EditionMenuCollectionControllerConstants.section)
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
    
    /// shows or hides the filter selector
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
        if let cell = cell as? EditionMenuCollectionCell {
            cell.bindTo(editionOptions[indexPath.item])
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard editionOptions.count > 0, collectionView.bounds != .zero else { return .zero }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: EditionMenuCollectionControllerConstants.horizontalInset)
    }
    
    // MARK: Option selection
    
    /// Selects an option
    ///
    /// - Parameter index: position of the option in the collection
    private func selectEditionOption(index: Int) {
        selectedIndexPath = IndexPath(item: index, section: EditionMenuCollectionControllerConstants.section)
        delegate?.didSelectEditionOption(editionOptions[index])
    }
    
}
