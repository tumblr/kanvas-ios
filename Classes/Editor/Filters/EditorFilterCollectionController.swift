//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol EditorFilterCollectionControllerDelegate: class {
    /// Callback for when a filter item is selected
    ///
    /// - Parameter filterItem: the selected filter
    func didSelectFilter(_ filterItem: FilterItem)
}

/// Constants for Collection Controller
private struct EditorFilterCollectionControllerConstants {
    static let animationDuration: TimeInterval = 0.25
    static let initialCell: Int = 0
    static let section: Int = 0
    static let leftInset: CGFloat = 11
}

/// Controller for handling the filter item collection.
final class EditorFilterCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FilterCollectionCellDelegate, ScrollHandlerDelegate {
    
    static let leftInset = EditorFilterCollectionControllerConstants.leftInset
    
    private lazy var filterCollectionView = FilterCollectionView(cellWidth: EditorFilterCollectionCell.width, cellHeight: EditorFilterCollectionCell.minimumHeight)
    private var filterItems: [FilterItem]
    private var selectedIndexPath: IndexPath
    private var scrollHandler: ScrollHandler?
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    weak var delegate: EditorFilterCollectionControllerDelegate?
    
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
        selectedIndexPath = IndexPath(item: EditorFilterCollectionControllerConstants.initialCell, section: EditorFilterCollectionControllerConstants.section)
        
        super.init(nibName: .none, bundle: .none)
        
        scrollHandler = ScrollHandler(collectionView: filterCollectionView.collectionView, cellWidth: EditorFilterCollectionCell.width, cellHeight: EditorFilterCollectionCell.minimumHeight)
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
        filterCollectionView.collectionView.register(cell: EditorFilterCollectionCell.self)
        filterCollectionView.collectionView.delegate = self
        filterCollectionView.collectionView.dataSource = self
        setUpRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToOptionAt(EditorFilterCollectionControllerConstants.initialCell, animated: false)
        filterCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        filterCollectionView.collectionView.layoutIfNeeded()
        changeSize(IndexPath(item: EditorFilterCollectionControllerConstants.initialCell, section: EditorFilterCollectionControllerConstants.section))
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
        UIView.animate(withDuration: EditorFilterCollectionControllerConstants.animationDuration) {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditorFilterCollectionCell.identifier, for: indexPath)
        if let cell = cell as? EditorFilterCollectionCell {
            cell.bindTo(filterItems[indexPath.item])
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard filterItems.count > 0, collectionView.bounds != .zero else { return .zero }
        let cellsOnScreen = filterCollectionView.collectionView.frame.width / EditorFilterCollectionCell.width
        let rightInset = (cellsOnScreen - 1) * EditorFilterCollectionCell.width
        return UIEdgeInsets(top: 0, left: EditorFilterCollectionControllerConstants.leftInset, bottom: 0, right: rightInset)
    }
    
    // MARK: - Scrolling
    
    func scrollToOptionAt(_ index: Int, animated: Bool = true) {
        guard filterCollectionView.collectionView.numberOfItems(inSection: 0) > index else { return }
        let indexPath = IndexPath(item: index, section: EditorFilterCollectionControllerConstants.section)
        scrollToItemPreservingLeftInset(indexPath: indexPath, animated: animated)
        selectFilter(index: indexPath.item)
    }
    
    func scrollToItemPreservingLeftInset(indexPath: IndexPath, animated: Bool) {
        guard let layout = filterCollectionView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
            let attri = layout.layoutAttributesForItem(at: indexPath) else { return }
        
        let point = CGPoint(x: (attri.frame.origin.x - EditorFilterCollectionControllerConstants.leftInset), y: 0)
        filterCollectionView.collectionView.setContentOffset(point, animated: animated)
    }
    
    func indexPathAtSelectionCircle() -> IndexPath? {
        let x = EditorFilterCollectionControllerConstants.leftInset + (EditorFilterCollectionCell.width / 2) + filterCollectionView.collectionView.contentOffset.x
        let y = filterCollectionView.collectionView.center.y + filterCollectionView.collectionView.contentOffset.y
        let point: CGPoint = CGPoint(x: x, y: y)
        return filterCollectionView.collectionView.indexPathForItem(at: point)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollHandler?.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollHandler?.scrollViewDidScroll(scrollView)
    }
    
    @objc func collectionTapped() {
        scrollHandler?.collectionTapped()
    }
    
    // MARK: - Animate size change
    
    /// Changes the cell size according to its distance from center
    ///
    /// - Parameter indexPath: the index path of the cell
    private func changeSize(_ indexPath: IndexPath) {
        let cell = filterCollectionView.collectionView.cellForItem(at: indexPath) as? EditorFilterCollectionCell
        if let cell = cell {
            let maxDistance = EditorFilterCollectionCell.width / 2
            let distance = calculateDistanceFromSelectionCircle(cell: cell)
            let percent = (maxDistance - distance) / maxDistance
            cell.setSize(percent: percent)
        }
    }
    
    // MARK: Filter selection
    
    /// Selects a filter
    ///
    /// - Parameter index: position of the filter in the collection
    func selectFilter(index: Int) {
        if isViewVisible() {
            feedbackGenerator.notificationOccurred(.success)
        }
        selectedIndexPath = IndexPath(item: index, section: EditorFilterCollectionControllerConstants.section)
        delegate?.didSelectFilter(filterItems[index])
    }
    
    func calculateDistanceFromSelectionCircle(cell: FilterCollectionCell) -> CGFloat {
        let cellCenter = cell.frame.center.x
        let firstCellCenter = EditorFilterCollectionControllerConstants.leftInset + (EditorFilterCollectionCell.width / 2) + filterCollectionView.collectionView.contentOffset.x
        return abs(firstCellCenter - cellCenter)
    }
    
    /// Sets the cell with the standard size (smallest size)
    ///
    /// - Parameter indexPath: the index path of the cell
    private func resetSize(for indexPath: IndexPath) {
        scrollHandler?.resetSize(for: indexPath)
    }
    
    // MARK: - FilterCollectionCellDelegate
    
    func didTap(cell: FilterCollectionCell, recognizer: UITapGestureRecognizer) {
        if let cell = cell as? EditorFilterCollectionCell, let indexPath = filterCollectionView.collectionView.indexPath(for: cell) {
            scrollToOptionAt(indexPath.item)
        }
    }
    
    func didLongPress(cell: FilterCollectionCell, recognizer: UILongPressGestureRecognizer) {
        
    }
}
