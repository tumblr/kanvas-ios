//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol MediaClipsCollectionControllerDelegate: class {

    /// Callback for when a clip is selected
    func mediaClipWasSelected(at index: Int)

    /// Callback for when a clip is deselected
    func mediaClipWasDeselected(at index: Int)
    
    /// Callback for when a clip is moved inside the collection
    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int)
    
    /// Callback for when a clips starts moving / dragging
    func mediaClipStartedMoving()
    
    /// Callback for when a clip finishes moving / draggin
    func mediaClipFinishedMoving()
}

/// Controller for handling the media clips collection.
final class MediaClipsCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private lazy var mediaClipsCollectionView = MediaClipsCollectionView()

    private var clips: [MediaClip]
    private var selectedClipIndex: IndexPath?

    weak var delegate: MediaClipsCollectionControllerDelegate?

    init() {
        clips = []
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

    /// Adds a new clip and updates the UI
    ///
    /// - Parameter clip: The media clip to display
    func addNewClip(_ clip: MediaClip) {
        deselectOldSelection(in: mediaClipsCollectionView.collectionView)
        clips.append(clip)
        mediaClipsCollectionView.collectionView.insertItems(at: [IndexPath(item: clips.count - 1, section: 0)])
        if mediaClipsCollectionView.collectionView.numberOfItems(inSection: 0) > 0 {
            scrollToLast(animated: true)
        }
    }

    /// Deletes the last clip and updates the UI
    func removeLastClip() {
        deselectOldSelection(in: mediaClipsCollectionView.collectionView)
        if clips.count > 0 {
            let index = clips.count - 1
            if index == selectedClipIndex?.item {
                selectedClipIndex = .none
            }
            clips.removeLast()
            mediaClipsCollectionView.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }

    /// Deletes the current selected clip and updates UI
    ///
    /// - Returns: the index of the selected clip
    func removeSelectedClip() -> Int? {
        if let index = selectedClipIndex {
            selectedClipIndex = .none
            clips.remove(at: index.item)
            mediaClipsCollectionView.collectionView.deleteItems(at: [index])
            return index.item
        }
        else {
            return .none
        }
    }

    /// Returns the current clips added in the UI
    ///
    /// - Returns: MediaClip array
    func getClips() -> [MediaClip] {
        return clips
    }

    // MARK: - View Life Cycle
    override func loadView() {
        view = mediaClipsCollectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mediaClipsCollectionView.collectionView.register(cell: MediaClipsCollectionCell.self)
        mediaClipsCollectionView.collectionView.delegate = self
        mediaClipsCollectionView.collectionView.dataSource = self
        mediaClipsCollectionView.collectionView.dragDelegate = self
        mediaClipsCollectionView.collectionView.dropDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mediaClipsCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        mediaClipsCollectionView.collectionView.layoutIfNeeded()
        if mediaClipsCollectionView.collectionView.numberOfItems(inSection: 0) > 0 {
            scrollToLast(animated: false)
        }
    }

    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clips.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaClipsCollectionCell.identifier, for: indexPath)
        if let mediaCell = cell as? MediaClipsCollectionCell {
            mediaCell.bindTo(clips[indexPath.item])
        }
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !collectionView.hasActiveDrag else { return }
        let item = selectedClipIndex?.item
        deselectOldSelection(in: collectionView)
        if item != indexPath.item {
            deselectOldSelection(in: collectionView)
            let cell = collectionView.cellForItem(at: indexPath) as? MediaClipsCollectionCell
            cell?.setSelected(true)
            selectedClipIndex = indexPath
            let index = indexPath.item
            scrollToOptionAt(index, animated: true)
            delegate?.mediaClipWasSelected(at: index)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard clips.count > 0, collectionView.bounds != .zero else { return .zero }

        let leftInset = cellBorderWhenCentered(firstCell: true, leftBorder: true, collectionView: collectionView)
        let rightInset = cellBorderWhenCentered(firstCell: false, leftBorder: false, collectionView: collectionView)

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

    private func cellBorderWhenCentered(firstCell: Bool, leftBorder: Bool, collectionView: UICollectionView) -> CGFloat {
        let cellMock = MediaClipsCollectionCell(frame: .zero)
        if firstCell, let firstClip = clips.first {
            cellMock.bindTo(firstClip)
        }
        else if let lastClip = clips.last {
            cellMock.bindTo(lastClip)
        }
        let cellSize = cellMock.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let cellWidth = cellSize.width
        let center = collectionView.center.x
        let border = leftBorder ? center - cellWidth/2 : center + cellWidth/2
        let inset = leftBorder ? border : collectionView.bounds.width - border
        return inset
    }

    // MARK: - Scrolling
    func scrollToLast(animated: Bool) {
        scrollToOptionAt(clips.count-1, animated: animated)
    }

    private func scrollToOptionAt(_ index: Int, animated: Bool) {
        guard mediaClipsCollectionView.collectionView.numberOfItems(inSection: 0) > index else { return }
        let indexPath = IndexPath(item: index, section: 0)
        mediaClipsCollectionView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        if !animated {
            mediaClipsCollectionView.collectionView.reloadData()
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        deselectOldSelection(in: mediaClipsCollectionView.collectionView)
    }

    // MARK: - Helpers
    private func deselectOldSelection(in collectionView: UICollectionView) {
        let oldSelected = selectedClipIndex.flatMap { collectionView.cellForItem(at: $0) as? MediaClipsCollectionCell }
        oldSelected?.setSelected(false)
        if let index = selectedClipIndex?.item {
            selectedClipIndex = .none
            delegate?.mediaClipWasDeselected(at: index)
        }
    }

}

// MARK: - UICollectionViewDragDelegate
extension MediaClipsCollectionController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        deselectOldSelection(in: collectionView)
        let item = clips[indexPath.item]
        // Local object won't be used
        let itemProvider = NSItemProvider(object: item.representativeFrame)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item.representativeFrame
        delegate?.mediaClipStartedMoving()
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        return parameters
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        delegate?.mediaClipFinishedMoving()
    }
}

// MARK: - UICollectionViewDropDelegate
extension MediaClipsCollectionController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let item = coordinator.items.first, let oldIndexPath = item.sourceIndexPath else { return }
        let oldIndex = oldIndexPath.item
        if coordinator.destinationIndexPath == nil {
            NSLog("Destination Drag index path is nil: strange things may happen.")
        }
        let newIndexPath = coordinator.destinationIndexPath ?? oldIndexPath
        let newIndex = newIndexPath.item
        clips.move(from: oldIndex, to: newIndex)
        collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
        coordinator.drop(item.dragItem, toItemAt: newIndexPath)
        delegate?.mediaClipWasMoved(from: oldIndex, to: newIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        if let cellSize = collectionView.visibleCells.first?.bounds {
            parameters.visiblePath = UIBezierPath(rect: CGRect(x: cellSize.center.x, y: cellSize.center.y, width: 0, height: 0))
        }
        return parameters
    }
    
}
