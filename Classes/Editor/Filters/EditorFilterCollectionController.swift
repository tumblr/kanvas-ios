//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol EditorFilterCollectionControllerDelegate: AnyObject {
    /// Callback for when a filter item is selected
    ///
    /// - Parameter filterItem: the selected filter
    func didSelectFilter(_ filterItem: FilterItem)
}

/// Constants for Collection Controller
private struct EditorFilterCollectionControllerConstants {
    static let animationDuration: TimeInterval = 0.25
    static let horizontalInset: CGFloat = 10
    static let initialCell: Int = 0
    static let section: Int = 0
    static let scrollingThreshold: CGFloat = 9.0
}

/// Controller for handling the filter item collection.
final class EditorFilterCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FilterCollectionCellDelegate {
        
    private lazy var filterCollectionView = FilterCollectionView(cellWidth: EditorFilterCollectionCell.width,
                                                                 cellHeight: EditorFilterCollectionCell.minimumHeight)
    private var filterItems: [FilterItem]
    private var selectedIndexPath: IndexPath
    private var scrollingStartPoint: CGPoint
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
        
        scrollingStartPoint = .zero
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
        filterCollectionView.collectionView.register(cell: EditorFilterCollectionCell.self)
        filterCollectionView.collectionView.delegate = self
        filterCollectionView.collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        filterCollectionView.collectionView.layoutIfNeeded()
        filterCollectionView.shrink()
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
        if show {
            self.filterCollectionView.pop()
        }
        else {
            self.filterCollectionView.shrink()
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
            
            if indexPath == selectedIndexPath {
                cell.setSelected(true)
            }
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard filterItems.count > 0, collectionView.bounds != .zero else { return .zero }
        return UIEdgeInsets(top: 0, left: EditorFilterCollectionControllerConstants.horizontalInset,
                            bottom: 0, right: EditorFilterCollectionControllerConstants.horizontalInset)
    }
    
    // MARK: Filter selection
    
    /// Selects a filter
    ///
    /// - Parameter index: position of the filter in the collection
    func selectFilter(index: Int) {
        if isViewVisible() {
            feedbackGenerator.notificationOccurred(.success)
        }
        delegate?.didSelectFilter(filterItems[index])
    }
    
    // MARK: - Cell selection
    
    private func selectCell(_ cell: FilterCollectionCell) {
        guard let cell = cell as? EditorFilterCollectionCell,
            let indexPath = filterCollectionView.collectionView.indexPath(for: cell) else { return }
        
        cell.setSelected(true)
        selectedIndexPath = indexPath
        selectFilter(index: indexPath.item)
    }
    
    // MARK: - FilterCollectionCellDelegate
    
    func didTap(cell: FilterCollectionCell, recognizer: UITapGestureRecognizer) {
        // Delegate method. Does nothing in this case.
    }
    
    func didLongPress(cell: FilterCollectionCell, recognizer: UILongPressGestureRecognizer) {
        let previousCell = filterCollectionView.collectionView.cellForItem(at: selectedIndexPath) as? EditorFilterCollectionCell
        
        switch recognizer.state {
        case .began:
            scrollingStartPoint = recognizer.location(in: recognizer.view)
            cell.press()
        case .changed:
            let location = recognizer.location(in: recognizer.view)
            if abs(scrollingStartPoint.x - location.x) > EditorFilterCollectionControllerConstants.scrollingThreshold ||
                abs(scrollingStartPoint.y - location.y) > EditorFilterCollectionControllerConstants.scrollingThreshold {
                // Disabling the recognizer makes it cancel the gesture
                recognizer.isEnabled = false
            }
        case .ended:
            // Deselect previous cell
            if previousCell != cell {
                previousCell?.setSelected(false)
            }
            selectCell(cell)
        case .cancelled:
            recognizer.isEnabled = true
            // Make cell go back to previous state
            let selectedBefore = previousCell == cell
            cell.setSelected(selectedBefore)
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
}
