//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol FilterSmallCollectionControllerDelegate: class {
    /// Callback for when a filter item is selected
    ///
    /// - Parameter filterItem: the selected filter
    func didSelectFilter(_ filterItem: FilterItem)
}

/// Constants for Collection Controller
private struct FilterSmallCollectionControllerConstants {
    static let animationDuration: TimeInterval = 0.25
    static let initialCell: Int = 0
    static let section: Int = 0
    static let leftInset: CGFloat = 11
}

/// Controller for handling the filter item collection.
final class FilterSmallCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FilterSmallCollectionCellDelegate {
    
    private lazy var filterCollectionView = FilterSmallCollectionView()
    private var filterItems: [FilterItem]
    private var selectedIndexPath: IndexPath
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    weak var delegate: FilterSmallCollectionControllerDelegate?
    
    /// Initializes the collection
    init(settings: CameraSettings) {
        filterItems = [
            FilterItem(type: .passthrough),
            FilterItem(type: .wavePool),
            FilterItem(type: .plasma),
            FilterItem(type: .emInterference),
            FilterItem(type: .rgb),
            FilterItem(type: .lego),
            FilterItem(type: .chroma),
            FilterItem(type: .rave),
            FilterItem(type: .mirrorTwo),
            FilterItem(type: .mirrorFour),
            FilterItem(type: .lightLeaks),
            FilterItem(type: .film),
            FilterItem(type: .grayscale),
        ]
        if settings.features.experimentalCameraFilters {
            filterItems.append(contentsOf: [
                FilterItem(type: .manga),
                FilterItem(type: .toon),
                ])
        }
        selectedIndexPath = IndexPath(item: FilterSmallCollectionControllerConstants.initialCell, section: FilterSmallCollectionControllerConstants.section)
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
        view = filterCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterCollectionView.collectionView.register(cell: FilterSmallCollectionCell.self)
        filterCollectionView.collectionView.delegate = self
        filterCollectionView.collectionView.dataSource = self
        setUpView()
        setUpRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToOptionAt(FilterSmallCollectionControllerConstants.initialCell, animated: false)
        filterCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        filterCollectionView.collectionView.layoutIfNeeded()
        changeSize(IndexPath(item: FilterSmallCollectionControllerConstants.initialCell, section: FilterSmallCollectionControllerConstants.section))
    }
    
    private func setUpView() {
        filterCollectionView.alpha = 0
    }
    
    private func setUpRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(collectionTapped))
        filterCollectionView.collectionView.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - Public interface
    
    /// indicates whether the filter selector is visible
    ///
    /// - Returns: true if visible, false if hidden
    func isViewVisible() -> Bool {
        return filterCollectionView.alpha > 0
    }
    
    /// shows or hides the filter selector
    ///
    /// - Parameter show: true to show, false to hide
    func showView(_ show: Bool) {
        UIView.animate(withDuration: FilterSmallCollectionControllerConstants.animationDuration) {
            self.filterCollectionView.alpha = show ? 1 : 0
        }
    }
    
    /// Returns the collection of filter items
    ///
    /// - Returns: Filter item array
    func getFilterItems() -> [FilterItem] {
        return filterItems
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterSmallCollectionCell.identifier, for: indexPath)
        if let cell = cell as? FilterSmallCollectionCell {
            cell.bindTo(filterItems[indexPath.item])
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard filterItems.count > 0, collectionView.bounds != .zero else { return .zero }
        let cellsOnScreen = filterCollectionView.collectionView.frame.width / FilterSmallCollectionCell.width
        let rightInset = (cellsOnScreen - 1) * FilterSmallCollectionCell.width
        return UIEdgeInsets(top: 0, left: FilterSmallCollectionControllerConstants.leftInset, bottom: 0, right: rightInset)
    }
    
    // MARK: - Scrolling
    
    private func scrollToOptionAt(_ index: Int, animated: Bool = true) {
        guard filterCollectionView.collectionView.numberOfItems(inSection: 0) > index else { return }
        let indexPath = IndexPath(item: index, section: FilterSmallCollectionControllerConstants.section)
        scrollToItemPreservingLeftInset(indexPath: indexPath, animated: animated)
        selectFilter(index: indexPath.item)
    }
    
    func scrollToItemPreservingLeftInset(indexPath: IndexPath, animated: Bool) {
        let layout = filterCollectionView.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let attri = layout.layoutAttributesForItem(at: indexPath)!
        filterCollectionView.collectionView.setContentOffset(CGPoint(x: (attri.frame.origin.x - FilterSmallCollectionControllerConstants.leftInset), y: 0), animated: animated)
    }
    
    private func indexPathAtBeginning() -> IndexPath? {
        let x = FilterSmallCollectionControllerConstants.leftInset + (FilterSmallCollectionCell.width / 2) + filterCollectionView.collectionView.contentOffset.x
        let y = filterCollectionView.collectionView.center.y + filterCollectionView.collectionView.contentOffset.y
        let point: CGPoint = CGPoint(x: x, y: y)
        return filterCollectionView.collectionView.indexPathForItem(at: point)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x == 0 {
            if let indexPath = indexPathAtBeginning() {
                scrollToOptionAt(indexPath.item)
            }
        }
        else {
            let targetOffset = targetContentOffset.pointee
            let itemWidth = FilterSmallCollectionCell.width
            let roundedIndex = CGFloat(targetOffset.x / itemWidth).rounded()
            let newTargetOffset = roundedIndex * itemWidth
            targetContentOffset.pointee.x = newTargetOffset
            let itemIndex = Int(roundedIndex)
            selectFilter(index: itemIndex)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = indexPathAtBeginning() {
            changeSize(indexPath)
            resetSize(for: indexPath.previous())
            resetSize(for: indexPath.next())
        }
    }
    
    // When the collection is decelerating, but the user taps a cell to stop,
    // the collection needs to set a cell at the center of the screen
    @objc func collectionTapped() {
        if let indexPath = indexPathAtBeginning() {
            scrollToOptionAt(indexPath.item)
        }
    }
    
    // MARK: - Animate size change
    
    /// Changes the cell size according to its distance from center
    ///
    /// - Parameter indexPath: the index path of the cell
    private func changeSize(_ indexPath: IndexPath) {
        let cell = filterCollectionView.collectionView.cellForItem(at: indexPath) as? FilterSmallCollectionCell
        if let cell = cell {
            let maxDistance = FilterSmallCollectionCell.width / 2
            let distance = calculateDistanceFromFirstCell(cell: cell)
            let percent = (maxDistance - distance) / maxDistance
            cell.setSize(percent: percent)
        }
    }
    
    // MARK: Filter selection
    
    /// Selects a filter
    ///
    /// - Parameter index: position of the filter in the collection
    private func selectFilter(index: Int) {
        if isViewVisible() {
            feedbackGenerator.notificationOccurred(.success)
        }
        selectedIndexPath = IndexPath(item: index, section: FilterSmallCollectionControllerConstants.section)
        delegate?.didSelectFilter(filterItems[index])
    }
    
    private func calculateDistanceFromCenter(cell: FilterSmallCollectionCell) -> CGFloat {
        let cellCenter = cell.frame.center.x
        let collectionViewCenter = filterCollectionView.collectionView.center.x + filterCollectionView.collectionView.contentOffset.x
        return abs(collectionViewCenter - cellCenter)
    }
    
    private func calculateDistanceFromFirstCell(cell: FilterSmallCollectionCell) -> CGFloat {
        let cellCenter = cell.frame.center.x
        let firstCellCenter = FilterSmallCollectionControllerConstants.leftInset + (FilterSmallCollectionCell.width / 2) + filterCollectionView.collectionView.contentOffset.x
        return abs(firstCellCenter - cellCenter)
    }
    
    /// Sets the cell with the standard size (smallest size)
    ///
    /// - Parameter indexPath: the index path of the cell
    private func resetSize(for indexPath: IndexPath) {
        let cell = filterCollectionView.collectionView.cellForItem(at: indexPath) as? FilterSmallCollectionCell
        cell?.setStandardSize()
    }
    
    // MARK: - FilterSmallCollectionCellDelegate
    
    func didTap(cell: FilterSmallCollectionCell, recognizer: UITapGestureRecognizer) {
        if let indexPath = filterCollectionView.collectionView.indexPath(for: cell) {
            scrollToOptionAt(indexPath.item)
        }
    }
}

/// Next and previous index paths
private extension IndexPath {
    
    func previous() -> IndexPath {
        return IndexPath(item: item - 1, section: section)
    }
    
    func next() -> IndexPath {
        return IndexPath(item: item + 1, section: section)
    }
}
