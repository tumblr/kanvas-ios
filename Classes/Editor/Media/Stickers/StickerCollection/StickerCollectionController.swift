//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting a sticker
protocol StickerCollectionControllerDelegate: class {
    /// Callback for when a sticker is selected
    ///
    /// - Parameter sticker: the selected sticker
    func didSelectSticker(_ sticker: Sticker)
}

/// Constants for StickerCollectionController
private struct Constants {
    static let contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
    static let cacheSize: Int = 30
}

/// Controller for handling the sticker item collection.
final class StickerCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, StickerCollectionCellDelegate, StaggeredGridLayoutDelegate {
    
    weak var delegate: StickerCollectionControllerDelegate?
    
    private lazy var stickerCollectionView = StickerCollectionView()
    private let stickerProvider: StickerProvider
    private var stickerType: StickerType? = nil
    private var stickers: [Sticker] = []
    private var cellSizes: [CGSize] = []
    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = Constants.cacheSize
        return cache
    }()
    
    // MARK: - Initializers
    
    init(stickerProviderClass: StickerProvider.Type) {
        self.stickerProvider = stickerProviderClass.init()
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
        view = stickerCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stickerCollectionView.collectionView.register(cell: StickerCollectionCell.self)
        stickerCollectionView.collectionView.delegate = self
        stickerCollectionView.collectionView.dataSource = self
        stickerCollectionView.collectionViewLayout.delegate = self
    }

    // MARK: - Public interface
    
    /// Loads a new collection for a new sticker type
    ///
    /// - Parameter stickerType: the new sticker type
    func setType(_ stickerType: StickerType) {
        self.stickerType = stickerType
        stickers = stickerProvider.getStickers(for: stickerType)
        resetCellSizes()
        stickerCollectionView.collectionView.setContentOffset(.zero, animated: false)
        stickerCollectionView.collectionView.reloadData()
    }
    
    // MARK: - Private utilities
    
    private func resetCellSizes() {
        let cellWidth = stickerCollectionView.collectionViewLayout.itemWidth
        cellSizes = .init(repeating: CGSize(width: cellWidth, height: cellWidth), count: stickers.count)
    }
    
    // MARK: - StaggeredGridLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, heightOfCellAtIndexPath indexPath: IndexPath) -> CGFloat {
        let ratio = cellSizes[indexPath.item].height / cellSizes[indexPath.item].width
        return ratio * stickerCollectionView.collectionViewLayout.itemWidth
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCollectionCell.identifier, for: indexPath)
        if let cell = cell as? StickerCollectionCell, let sticker = stickers.object(at: indexPath.item), let type = stickerType {
            cell.bindTo(sticker, type: type, cache: imageCache, index: indexPath.item)
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: Sticker selection
    
    /// Selects a sticker
    ///
    /// - Parameter index: position of the sticker in the collection
    private func selectSticker(index: Int) {
        guard let sticker = stickers.object(at: index) else { return }
        delegate?.didSelectSticker(sticker)
    }
    
    // MARK: - StickerCollectionCellDelegate
    
    func didSelect(cell: StickerCollectionCell) {
        if let indexPath = stickerCollectionView.collectionView.indexPath(for: cell) {
            selectSticker(index: indexPath.item)
        }
    }
    
    func didLoadImage(index: Int, type: StickerType, image: UIImage) {
        guard let currentType = stickerType, type == currentType else { return }
        let currentSize = cellSizes[index]
        
        if currentSize != image.size {
            cellSizes[index] = image.size
            
            DispatchQueue.main.async { [weak self] in
                self?.stickerCollectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
}
