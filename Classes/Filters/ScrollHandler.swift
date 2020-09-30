//
//  ScrollHandler.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 21/06/2019.
//

import Foundation
import UIKit

protocol ScrollHandlerDelegate: class {
    func indexPathAtSelectionCircle() -> IndexPath?
    func calculateDistanceFromSelectionCircle(cell: FilterCollectionCell) -> CGFloat
    func selectFilter(index: Int, animated: Bool)
    func scrollToOption(at index: Int, animated: Bool)
}

final class ScrollHandler {
    
    private let collectionView: UICollectionView
    private let cellWidth: CGFloat
    private let cellHeight: CGFloat
    weak var delegate: ScrollHandlerDelegate?
    
    init(collectionView: UICollectionView, cellWidth: CGFloat, cellHeight: CGFloat) {
        self.collectionView = collectionView
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
    }
    
    /// Changes the cell size according to its distance from the selection circle
    ///
    /// - Parameter indexPath: the index path of the cell
    func changeSize(_ indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionCell
        if let cell = cell, let delegate = delegate {
            let maxDistance = cellWidth / 2
            let distance = delegate.calculateDistanceFromSelectionCircle(cell: cell)
            let percent = (maxDistance - distance) / maxDistance
            cell.setSize(percent: percent)
        }
    }
    
    /// Sets the cell with the standard size (smallest size)
    ///
    /// - Parameter indexPath: the index path of the cell
    func resetSize(for indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionCell
        cell?.setStandardSize()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let delegate = delegate else { return }
        if velocity.x == 0 {
            if let indexPath = delegate.indexPathAtSelectionCircle() {
                delegate.scrollToOption(at: indexPath.item, animated: true)
            }
        }
        else {
            let targetOffset = targetContentOffset.pointee
            let itemWidth = cellWidth
            let roundedIndex = CGFloat(targetOffset.x / itemWidth).rounded()
            let newTargetOffset = roundedIndex * itemWidth
            targetContentOffset.pointee.x = newTargetOffset
            let itemIndex = Int(roundedIndex)
            delegate.selectFilter(index: itemIndex, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let delegate = delegate, let indexPath = delegate.indexPathAtSelectionCircle() {
            changeSize(indexPath)
            resetSize(for: indexPath.previous())
            resetSize(for: indexPath.next())
        }
    }
}
