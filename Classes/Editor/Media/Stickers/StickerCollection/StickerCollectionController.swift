//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting a sticker
protocol StickerCollectionControllerDelegate: class {
    func didSelectSticker(_ sticker: Sticker)
}

/// Constants for StickerCollectionController
private struct Constants {
    static let contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
    static let cacheSize: Int = 30
}

/// Controller for handling the filter item collection.
final class StickerCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StickerCollectionCellDelegate, StaggeredGridLayoutDelegate {
    
    weak var delegate: StickerCollectionControllerDelegate?
    
    private lazy var stickerCollectionView = StickerCollectionView()
    private lazy var stickerProvider = StickerProvider()
    private var stickerType: StickerType? = nil
    private var stickers: [Sticker] = []
    private var cellSizes: [CGSize] = []
    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = Constants.cacheSize
        return cache
    }()
    
    /// Initializes the sticker collection
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
    
    func setType(_ stickerType: StickerType) {
        self.stickerType = stickerType
        stickers = stickerProvider.getStickers(for: stickerType)
        cellSizes = .init(repeating: .zero, count: stickers.count)
        stickerCollectionView.collectionView.setContentOffset(.zero, animated: false)
        stickerCollectionView.collectionView.reloadData()
    }
    
    // MARK: - StaggeredGridLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard cellSizes[indexPath.item] != .zero else { return 0 }
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
        let previousSize = cellSizes[index]
        cellSizes[index] = image.size
        if previousSize == .zero {
            DispatchQueue.main.async { [weak self] in
                self?.stickerCollectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
}
