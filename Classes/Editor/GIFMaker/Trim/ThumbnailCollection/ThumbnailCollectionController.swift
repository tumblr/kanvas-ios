//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for obtaining images.
protocol ThumbnailCollectionControllerDelegate: AnyObject {
    
    /// Obtains the full media duration
    func getMediaDuration() -> TimeInterval?
    
    /// Obtains a thumbnail for the background of the trimming tool
    ///
    /// - Parameter timestamp: the time of the requested image.
    func getThumbnail(at timestamp: TimeInterval) -> UIImage?
    
    /// Called when the thumbnail collection starts scrolling.
    func didBeginScrolling()
    
    /// Called when the thumbnail collection scrolls.
    func didScroll()
    
    /// Called when the thumbnail collection ends scrolling.
    func didEndScrolling()
}

/// Controller for handling the thumbnail collection in the trim menu.
final class ThumbnailCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ThumbnailCollectionViewLayoutDelegate, ThumbnailCollectionCellDelegate {
    
    weak var delegate: ThumbnailCollectionControllerDelegate?
    private lazy var thumbnailCollectionView = ThumbnailCollectionView()
        
    // MARK: - Initializers
    
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
        view = thumbnailCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thumbnailCollectionView.collectionView.register(cell: ThumbnailCollectionCell.self)
        thumbnailCollectionView.collectionView.delegate = self
        thumbnailCollectionView.collectionView.dataSource = self
        thumbnailCollectionView.collectionViewLayout.delegate = self
    }
    
    // MARK: - UICollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getCollectionSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCollectionCell.identifier, for: indexPath)
        
        if let cell = cell as? ThumbnailCollectionCell {
            let timeInterval = calculateTimestamp(for: indexPath)
            cell.delegate = self
            cell.bindTo(timeInterval)
        }
        return cell
    }
    
    // MARK: - ThumbnailCollectionViewLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, widthForCellAt indexPath: IndexPath) -> CGFloat {
        let itemCount = getCollectionSize()
        if indexPath.item == itemCount - 1 {
            let numberOfCells = getNumberOfCells()
            let visiblePercent = numberOfCells.truncatingRemainder(dividingBy: 1)
            return ThumbnailCollectionCell.cellWidth * CGFloat(visiblePercent)
        }
        else {
            return ThumbnailCollectionCell.cellWidth
        }
    }
    
    // MARK: - ThumbnailCollectionCellDelegate
    
    func getThumbnail(at timestamp: TimeInterval) -> UIImage? {
        return delegate?.getThumbnail(at: timestamp)
    }
    
    // MARK: - Public interface
    
    func reload(completion: ((Bool) -> Void)?) {
        let collectionView = thumbnailCollectionView.collectionView
        collectionView.reloadData()
        collectionView.performBatchUpdates(nil, completion: completion)
    }
    
    /// Obtains the frame that contains the visible cells.
    func getCellsFrame() -> CGRect {
        let collectionView = thumbnailCollectionView.collectionView
        
        guard let firstCell = collectionView.visibleCells.min(by: { $0.frame.midX < $1.frame.midX }),
            let lastCell = collectionView.visibleCells.max(by: { $0.frame.midX < $1.frame.midX })
            else { return .zero }
        
        let firstFrame = collectionView.convert(firstCell.frame, to: thumbnailCollectionView)
        let lastFrame = collectionView.convert(lastCell.frame, to: thumbnailCollectionView)
        
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
    
    /// Obtains the content offset of the collection at the location of the left gray handle. The value is expressed as a percentage.
    func getStartOfVisibleRange() -> CGFloat {
        let collectionView = thumbnailCollectionView.collectionView
        let percent = collectionView.contentOffset.x * 100 / collectionView.contentSize.width
        let min: CGFloat = 0
        let max: CGFloat = 100
        return (min...max).clamp(percent)
    }
    
    /// Obtains the content offset of the collection at the location of the right gray handle. The value is expressed as a percentage.
    func getEndOfVisibleRange() -> CGFloat {
        let collectionView = thumbnailCollectionView.collectionView
        let contentInset = collectionView.contentInset.left + collectionView.contentInset.right
        let percent = (collectionView.contentOffset.x + collectionView.visibleSize.width - contentInset) * 100 / collectionView.contentSize.width
        let min: CGFloat = 0
        let max: CGFloat = 100
        return (min...max).clamp(percent)
    }
    
    // MARK: - Private utilities
    
    /// Calculates the timestamp of the cell in relation to its position in the collection.
    ///
    /// - Parameters:
    ///  - indexPath: the index path of the cell.
    private func calculateTimestamp(for indexPath: IndexPath) -> TimeInterval {
        let timePerCell = calculateTimePerCell()
        let timeForCurrentCell = timePerCell.f * indexPath.item.f
        return TimeInterval(timeForCurrentCell)
    }
    
    /// Calculates the time interval that each cell represents.
    private func calculateTimePerCell() -> TimeInterval {
        guard let mediaDuration = delegate?.getMediaDuration() else { return 0 }
        let secondsBetweenHandles = min(mediaDuration.f, TrimController.maxSelectableTime.f)
        let numberOfCellsThatFitBetweenHandles = cellsThatFitBetweenHandles()
        return TimeInterval(secondsBetweenHandles / numberOfCellsThatFitBetweenHandles)
    }
    
    /// Obtains the number of cells that fit in the trimmer.
    private func cellsThatFitBetweenHandles() -> Float {
        let widthBetweenHandles = thumbnailCollectionView.collectionView.visibleSize.width - TrimView.selectorMargin * 2
        return widthBetweenHandles.f / ThumbnailCollectionCell.cellWidth.f
    }
    
    /// Obtains the number of cells considering the fraction of the last cell as well.
    private func getNumberOfCells() -> Float {
        guard let mediaDuration = delegate?.getMediaDuration() else { return 0 }
        let numberOfCells: Float
        
        if mediaDuration < TrimController.maxSelectableTime {
            numberOfCells = cellsThatFitBetweenHandles()
        }
        else {
            let timePerCell = calculateTimePerCell()
            numberOfCells = mediaDuration.f / timePerCell.f
        }
        
        return numberOfCells
    }
    
    /// Obtains the number of cells in the collection, expressed as an integer.
    private func getCollectionSize() -> Int {
        let cellsAsDecimal = getNumberOfCells()
        return Int(cellsAsDecimal.rounded(.up))
    }
}
