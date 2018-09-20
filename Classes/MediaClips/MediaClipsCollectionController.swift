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

        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
    }

    private func cellBorderWhenCentered(firstCell: Bool, leftBorder: Bool, collectionView: UICollectionView) -> CGFloat {
        let cellMock = MediaClipsCollectionCell(frame: .zero)
        if firstCell, let firstClip = clips.first {
            cellMock.bindTo(firstClip)
        }
        else if let lastClip = clips.last {
            cellMock.bindTo(lastClip)
        }
        let cellSize = cellMock.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
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
