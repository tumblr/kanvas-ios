//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for Collection Controller
private struct FilterSmallCollectionControllerConstants {
    static let leftInset: CGFloat = 11
}

/// Controller for handling the filter item collection.
final class FilterSmallCollectionController: FilterCollectionController {
    
    static let leftInset = FilterSmallCollectionControllerConstants.leftInset
    
    override internal func createFilterCollectionView() -> FilterCollectionView {
        return FilterSmallCollectionView()
    }
    
    override internal func getCollectionCellType() -> FilterCollectionCell.Type {
        return FilterSmallCollectionCell.self
    }
    
    // Needed despite being the same as in the superclass (prevents a bug from happening)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToOptionAt(initialCell, animated: false)
        filterCollectionView?.collectionView.collectionViewLayout.invalidateLayout()
        filterCollectionView?.collectionView.layoutIfNeeded()
        changeSize(IndexPath(item: initialCell, section: section))
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterSmallCollectionCell.identifier, for: indexPath)
        if let cell = cell as? FilterSmallCollectionCell {
            cell.bindTo(filterItems[indexPath.item])
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let filterCollectionView = filterCollectionView, filterItems.count > 0, collectionView.bounds != .zero else { return .zero }
        
        let cellsOnScreen = filterCollectionView.collectionView.frame.width / FilterSmallCollectionCellConstants.width
        let rightInset = (cellsOnScreen - 1) * FilterSmallCollectionCellConstants.width
        
        return UIEdgeInsets(top: 0, left: FilterSmallCollectionControllerConstants.leftInset, bottom: 0, right: rightInset)
    }
    
    // MARK: - Scrolling
    
    internal override func scrollToOptionAt(_ index: Int, animated: Bool = true) {
        guard let filterCollectionView = filterCollectionView,
            filterCollectionView.collectionView.numberOfItems(inSection: 0) > index else { return }
        let indexPath = IndexPath(item: index, section: section)
        scrollToItemPreservingLeftInset(indexPath: indexPath, animated: animated)
        selectFilter(index: indexPath.item)
    }
    
    private func scrollToItemPreservingLeftInset(indexPath: IndexPath, animated: Bool) {
        guard let filterCollectionView = filterCollectionView,
            let layout = filterCollectionView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
            let attri = layout.layoutAttributesForItem(at: indexPath) else { return }
        
        let point = CGPoint(x: (attri.frame.origin.x - FilterSmallCollectionControllerConstants.leftInset), y: 0)
        filterCollectionView.collectionView.setContentOffset(point, animated: animated)
    }
    
    private func indexPathAtBeginning() -> IndexPath? {
        guard let filterCollectionView = filterCollectionView else { return IndexPath(item: 0, section: 0) }
        let x = FilterSmallCollectionControllerConstants.leftInset + (FilterSmallCollectionCellConstants.width / 2) + filterCollectionView.collectionView.contentOffset.x
        let y = filterCollectionView.collectionView.center.y + filterCollectionView.collectionView.contentOffset.y
        let point: CGPoint = CGPoint(x: x, y: y)
        return filterCollectionView.collectionView.indexPathForItem(at: point)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x == 0 {
            if let indexPath = indexPathAtBeginning() {
                scrollToOptionAt(indexPath.item)
            }
        }
        else {
            let targetOffset = targetContentOffset.pointee
            let itemWidth = FilterSmallCollectionCellConstants.width
            let roundedIndex = CGFloat(targetOffset.x / itemWidth).rounded()
            let newTargetOffset = roundedIndex * itemWidth
            targetContentOffset.pointee.x = newTargetOffset
            let itemIndex = Int(roundedIndex)
            selectFilter(index: itemIndex)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = indexPathAtBeginning() {
            changeSize(indexPath)
            resetSize(for: indexPath.previous())
            resetSize(for: indexPath.next())
        }
    }
    
    // When the collection is decelerating, but the user taps a cell to stop,
    // the collection needs to set a cell at the center of the screen
    @objc override func collectionTapped() {
        if let indexPath = indexPathAtBeginning() {
            scrollToOptionAt(indexPath.item)
        }
    }
    
    // MARK: - Animate size change
    
    /// Changes the cell size according to its distance from center
    ///
    /// - Parameter indexPath: the index path of the cell
    override internal func changeSize(_ indexPath: IndexPath) {
        let cell = filterCollectionView?.collectionView.cellForItem(at: indexPath) as? FilterSmallCollectionCell
        if let cell = cell {
            let maxDistance = FilterSmallCollectionCellConstants.width / 2
            let distance = calculateDistanceFromFirstCell(cell: cell)
            let percent = (maxDistance - distance) / maxDistance
            cell.setSize(percent: percent)
        }
    }
    
    // MARK: Filter selection
    
    /// Selects a filter
    ///
    /// - Parameter index: position of the filter in the collection
    override internal func selectFilter(index: Int) {
        if isViewVisible() {
            feedbackGenerator.notificationOccurred(.success)
        }
        selectedIndexPath = IndexPath(item: index, section: section)
        delegate?.didSelectFilter(filterItems[index])
    }
    
    private func calculateDistanceFromFirstCell(cell: FilterSmallCollectionCell) -> CGFloat {
        guard let filterCollectionView = filterCollectionView else { return CGFloat(0) }
        let cellCenter = cell.frame.center.x
        let firstCellCenter = FilterSmallCollectionControllerConstants.leftInset + (FilterSmallCollectionCellConstants.width / 2) + filterCollectionView.collectionView.contentOffset.x
        return abs(firstCellCenter - cellCenter)
    }
    
    // MARK: - FilterCollectionCellDelegate
    
    override func didTap(cell: FilterCollectionCell, recognizer: UITapGestureRecognizer) {
        if let indexPath = filterCollectionView?.collectionView.indexPath(for: cell) {
            scrollToOptionAt(indexPath.item)
        }
    }
    
    override func didLongPress(cell: FilterCollectionCell, recognizer: UILongPressGestureRecognizer) {}
}
