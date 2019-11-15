//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol StickerCollectionControllerDelegate: class {
    func didSelectSticker(_ sticker: Sticker)
}

/// Constants for Sticker Controller
private struct StickerCollectionControllerConstants {
    static let animationDuration: TimeInterval = 0.25
    static let collectionInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
}

/// Controller for handling the filter item collection.
final class StickerCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, StickerCollectionCellDelegate {
    
    private lazy var stickerCollectionView = StickerCollectionView()
    private var stickers: [Sticker]
    
    weak var delegate: StickerCollectionControllerDelegate?
    
    /// Initializes the sticker collection
    init() {
        stickers = []
        for _ in 1...500 {
            stickers.append(Sticker(image: ""))
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
        view = stickerCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stickerCollectionView.collectionView.register(cell: StickerCollectionCell.self)
        stickerCollectionView.collectionView.delegate = self
        stickerCollectionView.collectionView.dataSource = self
    }

    // MARK: - Public interface
    
    /// shows or hides the sticker collection
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: StickerCollectionControllerConstants.animationDuration) {
            self.stickerCollectionView.alpha = show ? 1 : 0
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
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
        if let cell = cell as? StickerCollectionCell, let sticker = stickers.object(at: indexPath.item) {
            cell.bindTo(sticker)
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
    
    func didTap(cell: StickerCollectionCell, recognizer: UITapGestureRecognizer) {
        if let indexPath = stickerCollectionView.collectionView.indexPath(for: cell) {
            selectSticker(index: indexPath.item)
        }
    }
}

