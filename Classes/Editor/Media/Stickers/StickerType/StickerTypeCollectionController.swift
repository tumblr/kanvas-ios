//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting a sticker type
protocol StickerTypeCollectionControllerDelegate: class {
    func didSelectStickerType(_ stickerType: StickerType)
}

/// Constants for StickerTypeController
private struct Constants {
    static let initialIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    static let cacheSize: Int = 100
}

/// Controller for handling the sticker type collection.
final class StickerTypeCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StickerTypeCollectionCellDelegate {
    
    weak var delegate: StickerTypeCollectionControllerDelegate?
    
    private lazy var stickerTypeCollectionView = StickerTypeCollectionView()
    private lazy var stickerProvider = StickerProvider()
    private var stickerTypes: [StickerType] = []
    
    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = Constants.cacheSize
        return cache
    }()
    
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
    
    /// Initializes the sticker type collection
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
        view = stickerTypeCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stickerTypeCollectionView.collectionView.register(cell: StickerTypeCollectionCell.self)
        stickerTypeCollectionView.collectionView.delegate = self
        stickerTypeCollectionView.collectionView.dataSource = self
        
        stickerTypes = stickerProvider.getStickerTypes()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectedIndexPath = Constants.initialIndexPath
        selectStickerType(index:  Constants.initialIndexPath.item)
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
            cell.bindTo(stickerType, cache: imageCache)
            cell.delegate = self
            
            if indexPath == selectedIndexPath {
                cell.isSelected = true
            }
        }
        return cell
    }
    
    // MARK: Sticker type selection
    
    /// Selects a sticker
    ///
    /// - Parameter index: position of the sticker type in the collection
    private func selectStickerType(index: Int) {
        guard let stickerType = stickerTypes.object(at: index) else { return }
        delegate?.didSelectStickerType(stickerType)
    }
    
    // MARK: - StickerTypeCollectionCellDelegate
    
    func didTap(cell: StickerTypeCollectionCell) {
        if let indexPath = stickerTypeCollectionView.collectionView.indexPath(for: cell), indexPath != selectedIndexPath {
            selectedIndexPath = indexPath
            selectStickerType(index: indexPath.item)
        }
    }
}
