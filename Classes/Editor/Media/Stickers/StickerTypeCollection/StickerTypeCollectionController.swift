//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting a sticker type
protocol StickerTypeCollectionControllerDelegate: AnyObject {
    /// Callback for when a sticker type is selected
    ///
    /// - Parameter sticker: the selected sticker type
    func didSelectStickerType(_ stickerType: StickerType)
}

/// Constants for StickerTypeController
private struct Constants {
    static let initialIndexPath: IndexPath = IndexPath(item: 0, section: 0)
}

/// Controller for handling the sticker type collection.
final class StickerTypeCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StickerTypeCollectionCellDelegate, StickerProviderDelegate {
    
    weak var delegate: StickerTypeCollectionControllerDelegate?
    
    private lazy var stickerTypeCollectionView = StickerTypeCollectionView()
    private var stickerTypes: [StickerType] = []
    private let stickerProvider: StickerProvider?
    private let stickerLoader: KanvasStickerLoader?
    
    private var selectedIndexPath: IndexPath? {
        didSet {
            if let indexPath = oldValue,
                let cell = stickerTypeCollectionView.collectionView.cellForItem(at: indexPath) as? StickerTypeCollectionCell {
                cell.isSelected = false
            }
        }
        willSet {
            if let indexPath = newValue,
                let cell = stickerTypeCollectionView.collectionView.cellForItem(at: indexPath) as? StickerTypeCollectionCell {
                cell.isSelected = true
            }
        }
    }
    
    // MARK: - Initializers
    
    /// The designated initializer for the sticker type collection controller
    ///
    /// - Parameter stickerProvider: Class that will provide the stickers.
    init(stickerProvider: StickerProvider?) {
        self.stickerProvider = stickerProvider
        self.stickerLoader = stickerProvider?.loader()
        super.init(nibName: .none, bundle: .none)
        stickerProvider?.setDelegate(delegate: self)
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
        view = stickerTypeCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stickerTypeCollectionView.collectionView.register(cell: StickerTypeCollectionCell.self)
        stickerTypeCollectionView.collectionView.delegate = self
        stickerTypeCollectionView.collectionView.dataSource = self
        
        stickerProvider?.getStickerTypes()
    }

    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickerTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerTypeCollectionCell.identifier, for: indexPath)
        if let cell = cell as? StickerTypeCollectionCell, let stickerType = stickerTypes.object(at: indexPath.item) {
            cell.imageLoader = stickerLoader
            cell.bindTo(stickerType)
            cell.delegate = self
            
            if indexPath == selectedIndexPath {
                cell.isSelected = true
            }
        }
        return cell
    }
    
    // MARK: Sticker type selection
    
    /// Selects a sticker type
    ///
    /// - Parameter index: position of the sticker type in the collection
    private func selectStickerType(index: Int) {
        guard let stickerType = stickerTypes.object(at: index) else { return }
        delegate?.didSelectStickerType(stickerType)
    }
    
    // MARK: - StickerTypeCollectionCellDelegate
    
    func didSelect(cell: StickerTypeCollectionCell) {
        if let indexPath = stickerTypeCollectionView.collectionView.indexPath(for: cell), indexPath != selectedIndexPath {
            selectedIndexPath = indexPath
            selectStickerType(index: indexPath.item)
        }
    }
    
    // MARK: - StickerProviderDelegate
    
    func didLoadStickerTypes(_ stickerTypes: [StickerType]) {
        self.stickerTypes = stickerTypes
        stickerTypeCollectionView.collectionView.reloadData()
        
        if selectedIndexPath == nil {
            selectedIndexPath = Constants.initialIndexPath
            selectStickerType(index: Constants.initialIndexPath.item)
        }
    }
}
