//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for obtaining images.
protocol ThumbnailCollectionControllerDelegate: class {
    
    /// Obtains a thumbnail for the background of the trimming tool
    ///
    /// - Parameter index: the index of the requested image.
    func getThumbnail(at index: Int) -> UIImage?
    
    /// Called when the thumbnail collection starts scrolling.
    func didBeginScrolling()
    
    /// Called when the thumbnail collection scrolls.
    func didScroll()
    
    /// Called when the thumbnail collection ends scrolling.
    func didEndScrolling()
}

/// Controller for handling the thumbnail collection in the trim menu.
final class ThumbnailCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ThumbnailCollectionCellDelegate {
    
    weak var delegate: ThumbnailCollectionControllerDelegate?
    private lazy var thumbnailCollectionView = ThumbnailCollectionView()
    
    private var itemCount: Int
    
    // MARK: - Initializers
    
    init() {
        itemCount = 0
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
        view = thumbnailCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thumbnailCollectionView.collectionView.register(cell: ThumbnailCollectionCell.self)
        thumbnailCollectionView.collectionView.delegate = self
        thumbnailCollectionView.collectionView.dataSource = self
    }
    
    // MARK: - UICollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCollectionCell.identifier, for: indexPath)
        if let cell = cell as? ThumbnailCollectionCell {
            cell.delegate = self
            cell.bindTo(indexPath.item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: TrimView.selectorMargin, bottom: 0, right: TrimView.selectorMargin)
    }
    
    // MARK: - ThumbnailCollectionCellDelegate
    
    func getThumbnail(at index: Int) -> UIImage? {
        return delegate?.getThumbnail(at: index)
    }
    
    // MARK: - Public interface
    
    /// Sets the size of the thumbnail collection
    ///
    /// - Parameter count: the new size
    func setThumbnails(count: Int) {
        self.itemCount = count
        thumbnailCollectionView.collectionView.reloadData()
    }
    
    /// Obtains the frame that contains the visible cells.
    func getCellsFrame() -> CGRect {
        let collectionView = thumbnailCollectionView.collectionView
        var visibleCells = collectionView.visibleCells
        visibleCells.sort(by: { $0.frame.minX < $1.frame.minX })
        
        guard let firstCell = visibleCells.first, let lastCell = visibleCells.last
            else { return .zero }
        
        let firstFrame = thumbnailCollectionView.collectionView.convert(firstCell.frame, to: thumbnailCollectionView)
        let lastFrame = thumbnailCollectionView.collectionView.convert(lastCell.frame, to: thumbnailCollectionView)
        
        let rect = CGRect(x: firstFrame.origin.x,
                          y: firstFrame.origin.y,
                          width: lastFrame.maxX - firstFrame.minX,
                          height: firstFrame.maxY - firstFrame.minY)
        
        return rect
    }
    
    // MARK: - UIScrollView
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.didBeginScrolling()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.didEndScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            delegate?.didEndScrolling()
        }
    }
    
    func getStartOfVisibleRange() -> CGFloat {
        let collectionView = thumbnailCollectionView.collectionView
        let percent = collectionView.contentOffset.x * 100 / collectionView.contentSize.width
        let min: CGFloat = 0
        let max: CGFloat = 100
        return (min...max).clamp(percent)
    }
    
    func getEndOfVisibleRange() -> CGFloat {
        let collectionView = thumbnailCollectionView.collectionView
        let contentInset = collectionView.contentInset.left + collectionView.contentInset.right
        let percent = (collectionView.contentOffset.x + collectionView.visibleSize.width - contentInset) * 100 / collectionView.contentSize.width
        let min: CGFloat = 0
        let max: CGFloat = 100
        return (min...max).clamp(percent)
    }
}
