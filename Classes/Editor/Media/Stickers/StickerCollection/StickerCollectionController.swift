//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for selecting a sticker
protocol StickerCollectionControllerDelegate: AnyObject {
    /// Callback for when a sticker is selected
    /// 
    /// - Parameters
    ///  - id: the sticker id
    ///  - image: the sticker image
    ///  - size: image view size
    func didSelectSticker(id: String, image: UIImage, with size: CGSize)
}

/// Constants for StickerCollectionController
private struct Constants {
    static let contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
}

/// Controller for handling the sticker item collection.
final class StickerCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, StickerCollectionCellDelegate, StaggeredGridLayoutDelegate {
    
    weak var delegate: StickerCollectionControllerDelegate?
    
    private lazy var stickerCollectionView = StickerCollectionView()
    private var stickerType: StickerType? = nil
    var stickerLoader: KanvasStickerLoader?
    private var stickers: [Sticker] = []
    private var cellSizes: [CGSize] = []
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
    
    /// Loads a new collection of stickers for a selected sticker type
    ///
    /// - Parameter stickerType: the selected sticker type
    func setType(_ stickerType: StickerType) {
        self.stickerType = stickerType
        stickers = stickerType.stickers
        resetCellSizes()
        scrollToTop()
        stickerCollectionView.collectionView.reloadData()
    }
    
    // MARK: - Private utilities
    
    private func resetCellSizes() {
        let cellWidth = stickerCollectionView.collectionViewLayout.itemWidth
        cellSizes = .init(repeating: CGSize(width: cellWidth, height: cellWidth), count: stickers.count)
    }
    
    private func scrollToTop() {
        let indexPath = IndexPath(item: 0, section: 0)
        guard let _ = stickerCollectionView.collectionView.cellForItem(at: indexPath) else { return }
        stickerCollectionView.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
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
            cell.imageLoader = stickerLoader
            cell.delegate = self
            cell.bindTo(sticker, type: type, index: indexPath.item)
        }
        return cell
    }
        
    // MARK: - StickerCollectionCellDelegate
    
    func didSelect(id: String, image: UIImage, with size: CGSize) {
        delegate?.didSelectSticker(id: id, image: image, with: size)
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
