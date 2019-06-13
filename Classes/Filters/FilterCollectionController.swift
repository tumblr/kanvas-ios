//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol FilterCollectionControllerDelegate: class {
    /// Callback for when a filter item is selected
    ///
    /// - Parameter filterItem: the selected filter
    func didSelectFilter(_ filterItem: FilterItem)
    
    /// Callback for when the selected filter is tapped
    ///
    /// - Parameter recognizer: the tap recognizer
    func didTapSelectedFilter(recognizer: UITapGestureRecognizer)
    
    /// Callback for when the selected filter is longpressed
    ///
    /// - Parameter recognizer: the longpress recognizer
    func didLongPressSelectedFilter(recognizer: UILongPressGestureRecognizer)
}

/// Controller for handling the filter item collection.
class FilterCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FilterCollectionCellDelegate {
    
    internal var filterCollectionView: FilterCollectionView!
    internal var filterItems: [FilterItem]
    internal var selectedIndexPath: IndexPath
    internal let feedbackGenerator = UINotificationFeedbackGenerator()
    
    internal let animationDuration = 0.25
    internal let initialCell: Int = 0
    internal let section: Int = 0
    
    weak var delegate: FilterCollectionControllerDelegate?
    
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
        selectedIndexPath = IndexPath(item: initialCell, section: section)
        super.init(nibName: .none, bundle: .none)
        filterCollectionView = createFilterCollectionView()
    }
    
    internal func createFilterCollectionView() -> FilterCollectionView {
        return FilterCollectionView()
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
        filterCollectionView.collectionView.register(cell: getCollectionCellType())
        filterCollectionView.collectionView.delegate = self
        filterCollectionView.collectionView.dataSource = self
        setUpView()
        setUpRecognizers()
    }
    
    internal func getCollectionCellType() -> FilterCollectionCell.Type {
        return FilterCollectionCell.self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToOptionAt(initialCell, animated: false)
        filterCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        filterCollectionView.collectionView.layoutIfNeeded()
        changeSize(IndexPath(item: initialCell, section: section))
    }
    
    private func setUpView() {
        filterCollectionView.alpha = 0
    }
    
    private func setUpRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(collectionTapped))
        filterCollectionView?.collectionView.addGestureRecognizer(tapRecognizer)
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
        UIView.animate(withDuration: animationDuration) {
            self.filterCollectionView.alpha = show ? 1 : 0
        }
    }
    
    /// Updates the UI depending on whether recording is enabled
    ///
    /// - Parameter isRecording: if the UI should reflect that the user is currently recording
    func updateUI(forRecording isRecording: Bool) {
        filterCollectionView.collectionView.isUserInteractionEnabled = !isRecording
        showUnselectedFilters(!isRecording)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCollectionCell.identifier, for: indexPath)
        if let cell = cell as? FilterCollectionCell {
            cell.bindTo(filterItems[indexPath.item])
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard filterItems.count > 0, collectionView.bounds != .zero else { return .zero }
        
        let leftInset = cellBorderWhenCentered(firstCell: true, leftBorder: true, collectionView: collectionView)
        let rightInset = cellBorderWhenCentered(firstCell: false, leftBorder: false, collectionView: collectionView)
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    private func cellBorderWhenCentered(firstCell: Bool, leftBorder: Bool, collectionView: UICollectionView) -> CGFloat {
        let cellMock = FilterCollectionCell(frame: .zero)
        if firstCell, let firstFilter = filterItems.first {
            cellMock.bindTo(firstFilter)
        }
        else if let lastFilter = filterItems.last {
            cellMock.bindTo(lastFilter)
        }
        let cellWidth = FilterCollectionCellConstants.width
        let center = collectionView.center.x
        let border = leftBorder ? center - cellWidth / 2 : center + cellWidth / 2
        let inset = leftBorder ? border : collectionView.bounds.width - border
        return inset
    }
    
    // MARK: - Scrolling
    
    internal func scrollToOptionAt(_ index: Int, animated: Bool = true) {
        guard filterCollectionView.collectionView.numberOfItems(inSection: 0) > index else { return }
        let indexPath = IndexPath(item: index, section: section)
        filterCollectionView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        selectFilter(index: indexPath.item)
    }
    
    private func indexPathAtCenter() -> IndexPath? {
        let x = filterCollectionView.collectionView.center.x + filterCollectionView.collectionView.contentOffset.x
        let y = filterCollectionView.collectionView.center.y + filterCollectionView.collectionView.contentOffset.y
        let point: CGPoint = CGPoint(x: x, y: y)
        return filterCollectionView.collectionView.indexPathForItem(at: point)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x == 0 {
            if let indexPath = indexPathAtCenter() {
                scrollToOptionAt(indexPath.item)
            }
        }
        else {
            let targetOffset = targetContentOffset.pointee
            let itemWidth = FilterCollectionCellConstants.width
            let roundedIndex = CGFloat(targetOffset.x / itemWidth).rounded()
            let newTargetOffset = roundedIndex * itemWidth
            targetContentOffset.pointee.x = newTargetOffset
            let itemIndex = Int(roundedIndex)
            selectFilter(index: itemIndex)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = indexPathAtCenter() {
            changeSize(indexPath)
            resetSize(for: indexPath.previous())
            resetSize(for: indexPath.next())
        }
    }
    
    // When the collection is decelerating, but the user taps a cell to stop,
    // the collection needs to set a cell at the center of the screen
    @objc func collectionTapped() {
        if let indexPath = indexPathAtCenter() {
            scrollToOptionAt(indexPath.item)
        }
    }
    
    // MARK: - Animate size change
    
    /// Changes the cell size according to its distance from center
    ///
    /// - Parameter indexPath: the index path of the cell
    internal func changeSize(_ indexPath: IndexPath) {
        let cell = filterCollectionView.collectionView.cellForItem(at: indexPath) as? FilterCollectionCell
        if let cell = cell {
            let maxDistance = FilterCollectionCellConstants.width / 2
            let distance = calculateDistanceFromCenter(cell: cell)
            let percent = (maxDistance - distance) / maxDistance
            cell.setSize(percent: percent)
        }
    }
    
    // MARK: - Unselected filters
    
    /// Shows or hides the unselected filters
    ///
    /// - Parameter show: true to show, false to hide
    private func showUnselectedFilters(_ show: Bool) {
        let unselectedCells = getUnselectedCells()
        unselectedCells.forEach { cell in
            cell.show(show)
        }
    }
    
    /// Gets all the visible cells that are not inside the shutter button
    ///
    /// - Returns: the collection of unselected cells
    private func getUnselectedCells() -> [FilterCollectionCell] {
        guard let visibleCells = filterCollectionView.collectionView.visibleCells as? [FilterCollectionCell] else { return [] }
        let unselectedCells = visibleCells.filter { cell in
            filterCollectionView.collectionView.indexPath(for: cell) != selectedIndexPath
        }
        
        return unselectedCells
    }
    
    // MARK: Filter selection
    
    /// Selects a filter
    ///
    /// - Parameter index: position of the filter in the collection
    internal func selectFilter(index: Int) {
        selectedIndexPath = IndexPath(item: index, section: section)
        delegate?.didSelectFilter(filterItems[index])
    }
    
    private func calculateDistanceFromCenter(cell: FilterCollectionCell) -> CGFloat {
        let cellCenter = cell.frame.center.x
        let collectionViewCenter = filterCollectionView.collectionView.center.x + filterCollectionView.collectionView.contentOffset.x
        return abs(collectionViewCenter - cellCenter)
    }
    
    /// Sets the cell with the standard size (smallest size)
    ///
    /// - Parameter indexPath: the index path of the cell
    internal func resetSize(for indexPath: IndexPath) {
        let cell = filterCollectionView.collectionView.cellForItem(at: indexPath) as? FilterCollectionCell
        cell?.setStandardSize()
    }
    
    // MARK: - Private utilities
    
    /// Indicates if the cell is inside the shutter button
    ///
    /// - Parameter cell: the filter cell
    /// - Returns: true if the cell is inside the shutter button, false if not
    private func isSelectedCell(_ cell: FilterCollectionCell) -> Bool {
        let indexPath = filterCollectionView.collectionView.indexPath(for: cell)
        let centerIndexPath = indexPathAtCenter()
        return indexPath == centerIndexPath
    }

    // MARK: - FilterCollectionCellDelegate
    
    func didTap(cell: FilterCollectionCell, recognizer: UITapGestureRecognizer) {
        if isSelectedCell(cell) {
            delegate?.didTapSelectedFilter(recognizer: recognizer)
        }
        else if let indexPath = filterCollectionView?.collectionView.indexPath(for: cell) {
            scrollToOptionAt(indexPath.item)
        }
    }
    
    func didLongPress(cell: FilterCollectionCell, recognizer: UILongPressGestureRecognizer) {
        if isSelectedCell(cell) {
            delegate?.didLongPressSelectedFilter(recognizer: recognizer)
        }
    }
}

/// Next and previous index paths
internal extension IndexPath {
    
    func previous() -> IndexPath {
        return IndexPath(item: item - 1, section: section)
    }
    
    func next() -> IndexPath {
        return IndexPath(item: item + 1, section: section)
    }
}
