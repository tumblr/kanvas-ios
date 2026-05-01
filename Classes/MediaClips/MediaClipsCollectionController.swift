//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol MediaClipsCollectionControllerDelegate: AnyObject {
    
    /// Callback for when a clip is moved inside the collection
    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int)
    
    /// Callback for when a clips starts moving / dragging
    func mediaClipStartedMoving()
    
    /// Callback for when a clip finishes moving / draggin
    func mediaClipFinishedMoving()
    
    func mediaClipWasSelected(at: Int)
}

/// Constants for Collection Controller
private struct MediaClipsCollectionControllerConstants {
    /// Animation duration in seconds
    static let animationDuration: TimeInterval = 0.15
            
    /// Padding at each side of the clip collection
    static let leftInset: CGFloat = KanvasDesign.shared.mediaClipsCollectionControllerLeftInset
    static let rightInset: CGFloat = KanvasDesign.shared.mediaClipsCollectionControllerRightInset

}

/// Controller for handling the media clips collection.
final class MediaClipsCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private lazy var mediaClipsCollectionView = MediaClipsCollectionView(settings: settings.clipsCollectionViewSettings)

    private var clips: [MediaClip]
    private var draggingClipIndex: IndexPath?
    private weak var draggingCell: MediaClipsCollectionCell?

    weak var delegate: MediaClipsCollectionControllerDelegate?

    struct Settings {
        let clipsCollectionViewSettings: MediaClipsCollectionView.Settings
    }

    private let settings: Settings

    init(settings: Settings) {
        clips = []
        self.settings = settings
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
        clips.append(clip)
        mediaClipsCollectionView.collectionView.insertItems(at: [IndexPath(item: clips.count - 1, section: 0)])
        if mediaClipsCollectionView.collectionView.numberOfItems(inSection: 0) > 0 {
            scrollToLast(animated: true)
        }
    }

    func select(index: Int) {
        let selectedIndexPath = IndexPath(item: index, section: 0)
        guard mediaClipsCollectionView.collectionView.indexPathsForSelectedItems?.contains(selectedIndexPath) == false else {
            return
        }
        mediaClipsCollectionView.collectionView.indexPathsForSelectedItems?.forEach({ indexPath in
            mediaClipsCollectionView.collectionView.deselectItem(at: indexPath, animated: false)
        })
        let scrollPosition: UICollectionView.ScrollPosition
        if mediaClipsCollectionView.collectionView.indexPathsForVisibleItems.contains(selectedIndexPath) {
            scrollPosition = []
        } else {
            scrollPosition = .left
        }
        mediaClipsCollectionView.collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: scrollPosition)
    }

    func removeAllClips() {
        while clips.count > 0 {
            clips.remove(at: 0)
            mediaClipsCollectionView.collectionView.deleteItems(at: [IndexPath(item: 0, section: 0)])
        }
        mediaClipsCollectionView.collectionView.reloadData()
    }
    
    func replace(clips: [MediaClip]) {
        self.clips = clips.map({ $0 })
        mediaClipsCollectionView.collectionView.reloadData()
    }
    
    /// Deletes the current dragging clip and updates UI
    ///
    /// - Returns: the index of the selected clip
    func removeDraggingClip() -> Int? {
        if let index = draggingClipIndex {
            draggingClipIndex = .none
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
    
    /// Returns the last frame from the last clip of the collection
    func getLastFrameFromLastClip() -> UIImage? {
        return clips.last?.lastFrame
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
        mediaClipsCollectionView.updateFadeOutEffect()
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

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard clips.count > 0, collectionView.bounds != .zero else { return .zero }
        let insets = UIEdgeInsets(top: 0, left: MediaClipsCollectionControllerConstants.leftInset,
                                  bottom: 0, right: MediaClipsCollectionControllerConstants.rightInset)
        return insets
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: MediaClipsCollectionCell.width, height: MediaClipsCollectionCell.minimumHeight)
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

}

// MARK: - UICollectionViewDragDelegate
extension MediaClipsCollectionController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        draggingClipIndex = indexPath
        draggingCell = collectionView.cellForItem(at: indexPath) as? MediaClipsCollectionCell
        let item = clips[indexPath.item]
        // Local object won't be used
        let itemProvider = NSItemProvider(object: item.representativeFrame)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item.representativeFrame
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        draggingCell?.show(true)
        let parameters = UIDragPreviewParameters()
        parameters.backgroundColor = .clear
        return parameters
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        draggingCell?.show(false)
        delegate?.mediaClipStartedMoving()
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        delegate?.mediaClipFinishedMoving()
        draggingCell?.show(true)
        draggingCell = .none
        draggingClipIndex = .none
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.mediaClipWasSelected(at: indexPath.row)
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
        return parameters
    }
}
