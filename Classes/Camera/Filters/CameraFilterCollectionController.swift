//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol CameraFilterCollectionControllerDelegate: AnyObject {
    /// Callback for when a filter item is selected
    ///
    /// - Parameter filterItem: the selected filter
    func didSelectFilter(_ filterItem: FilterItem, animated: Bool)
    
    /// Callback for when the selected filter is tapped
    ///
    /// - Parameter recognizer: the tap recognizer
    func didTapSelectedFilter(recognizer: UITapGestureRecognizer)
    
    /// Callback for when the selected filter is longpressed
    ///
    /// - Parameter recognizer: the longpress recognizer
    func didLongPressSelectedFilter(recognizer: UILongPressGestureRecognizer)
}

/// Constants for Collection Controller
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
    static let initialIndex: Int = 0
    static let section: Int = 0
}

/// Controller for handling the filter item collection.
final class CameraFilterCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FilterCollectionCellDelegate, ScrollHandlerDelegate {
    
    private lazy var filterCollectionView = FilterCollectionView(cellWidth: CameraFilterCollectionCell.width, cellHeight: CameraFilterCollectionCell.minimumHeight, ignoreTouches: true)
    private var filterItems: [FilterItem]
    private var selectedIndexPath: IndexPath
    private var scrollHandler: ScrollHandler?
    private var unselectedCells: [CameraFilterCollectionCell] = []
    
    weak var delegate: CameraFilterCollectionControllerDelegate?
    
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
        
        selectedIndexPath = IndexPath(item: Constants.initialIndex, section: Constants.section)
        super.init(nibName: .none, bundle: .none)
        
        scrollHandler = ScrollHandler(collectionView: filterCollectionView.collectionView, cellWidth: CameraFilterCollectionCell.width, cellHeight: CameraFilterCollectionCell.minimumHeight)
        scrollHandler?.delegate = self
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
        filterCollectionView.collectionView.register(cell: CameraFilterCollectionCell.self)
        filterCollectionView.collectionView.delegate = self
        filterCollectionView.collectionView.dataSource = self
        setUpView()
        scrollToOption(at: Constants.initialIndex, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        filterCollectionView.collectionView.layoutIfNeeded()
        scrollHandler?.changeSize(IndexPath(item: Constants.initialIndex, section: Constants.section))
    }
    
    private func setUpView() {
        filterCollectionView.alpha = 0
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
        UIView.animate(withDuration: Constants.animationDuration) {
            self.filterCollectionView.alpha = show ? 1 : 0
        }
    }
    
    /// Updates the UI depending on whether recording is enabled
    ///
    /// - Parameter isRecording: if the UI should reflect that the user is currently recording
    func updateUI(forRecording isRecording: Bool) {
        if isRecording {
            filterCollectionView.collectionView.isUserInteractionEnabled = false
            hideUnselectedFilters()
        }
        else {
            filterCollectionView.collectionView.isUserInteractionEnabled = true
            showUnselectedFilters()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraFilterCollectionCell.identifier, for: indexPath)
        if let cell = cell as? CameraFilterCollectionCell {
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
        let cellMock = CameraFilterCollectionCell(frame: .zero)
        if firstCell, let firstFilter = filterItems.first {
            cellMock.bindTo(firstFilter)
        }
        else if let lastFilter = filterItems.last {
            cellMock.bindTo(lastFilter)
        }
        let cellWidth = CameraFilterCollectionCell.width
        let center = collectionView.center.x
        let border = leftBorder ? center - cellWidth / 2 : center + cellWidth / 2
        let inset = leftBorder ? border : collectionView.bounds.width - border
        return inset
    }
    
    // MARK: - Scrolling
    
    func scrollToOption(at index: Int, animated: Bool = true) {
        guard filterCollectionView.collectionView.numberOfItems(inSection: 0) > index else { return }
        let indexPath = IndexPath(item: index, section: Constants.section)
        filterCollectionView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        selectFilter(index: indexPath.item, animated: animated)
    }
    
    func scrollTo(_ cell: FilterCollectionCell, animated: Bool = true) {
        guard let indexPath = filterCollectionView.collectionView.indexPath(for: cell) else { return }
        scrollToOption(at: indexPath.item, animated: animated)
    }
    
    func indexPathAtSelectionCircle() -> IndexPath? {
        let x = filterCollectionView.collectionView.center.x + filterCollectionView.collectionView.contentOffset.x
        let y = filterCollectionView.collectionView.center.y + filterCollectionView.collectionView.contentOffset.y
        let point: CGPoint = CGPoint(x: x, y: y)
        return filterCollectionView.collectionView.indexPathForItem(at: point)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollHandler?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollHandler?.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - Unselected filters
    
    /// Hides the unselected filters
    private func hideUnselectedFilters() {
        unselectedCells = findUnselectedCells()
        unselectedCells.forEach { cell in
            cell.show(false)
        }
    }
    
    /// Shows the unselected filters
    private func showUnselectedFilters() {
        unselectedCells.forEach { cell in
            cell.show(true)
        }
        unselectedCells = []
    }
    
    /// Gets all the visible cells that are not inside the shutter button
    ///
    /// - Returns: the collection of unselected cells
    private func findUnselectedCells() -> [CameraFilterCollectionCell] {
        let collectionView = filterCollectionView.collectionView
        guard let visibleCells = collectionView.visibleCells as? [CameraFilterCollectionCell] else { return [] }
        let unselectedCells = visibleCells.filter { cell in
            collectionView.indexPath(for: cell) != selectedIndexPath
        }
        
        return unselectedCells
    }
    
    // MARK: Filter selection
    
    /// Selects a filter
    ///
    /// - Parameter index: position of the filter in the collection
    func selectFilter(index: Int, animated: Bool) {
        selectedIndexPath = IndexPath(item: index, section: Constants.section)
        delegate?.didSelectFilter(filterItems[index], animated: animated)
    }
    
    func calculateDistanceFromSelectionCircle(cell: FilterCollectionCell) -> CGFloat {
        let cellCenter = cell.frame.center.x
        let collectionViewCenter = filterCollectionView.collectionView.center.x + filterCollectionView.collectionView.contentOffset.x
        return abs(collectionViewCenter - cellCenter)
    }
    
    /// Sets the cell with the standard size (smallest size)
    ///
    /// - Parameter indexPath: the index path of the cell
    private func resetSize(for indexPath: IndexPath) {
        scrollHandler?.resetSize(for: indexPath)
    }
    
    // MARK: - Private utilities
    
    /// Indicates if the cell is inside the shutter button
    ///
    /// - Parameter cell: the filter cell
    /// - Returns: true if the cell is inside the shutter button, false if not
    private func isSelectedCell(_ cell: FilterCollectionCell) -> Bool {
        let indexPath = filterCollectionView.collectionView.indexPath(for: cell)
        let centerIndexPath = indexPathAtSelectionCircle()
        return indexPath == centerIndexPath
    }
    
    // MARK: - FilterCollectionCellDelegate
    
    func didTap(cell: FilterCollectionCell, recognizer: UITapGestureRecognizer) {
        if isSelectedCell(cell) {
            delegate?.didTapSelectedFilter(recognizer: recognizer)
        }

        scrollTo(cell)
    }
    
    func didLongPress(cell: FilterCollectionCell, recognizer: UILongPressGestureRecognizer) {
        if isSelectedCell(cell) {
            didLongPressSelectedCell(cell, recognizer: recognizer)
        }
        else {
            didLongPressUnselectedCell(cell, recognizer: recognizer)
        }
    }
    
    /// Called when the cell inside the shutter button is long pressed
    ///
    /// - Parameter cell: the cell being long pressed
    /// - Parameter recognizer: the long press gesture recognizer
    private func didLongPressSelectedCell(_ cell: FilterCollectionCell, recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            scrollTo(cell)
        }
        
        delegate?.didLongPressSelectedFilter(recognizer: recognizer)
    }
    
    /// Called when a cell outside the shutter button is long pressed
    ///
    /// - Parameter cell: the cell being long pressed
    /// - Parameter recognizer: the long press gesture recognizer
    private func didLongPressUnselectedCell(_ cell: FilterCollectionCell, recognizer: UILongPressGestureRecognizer) {
        guard let indexPath = indexPathAtSelectionCircle(), recognizer.state == .ended else { return }
        scrollToOption(at: indexPath.item)
    }
}
