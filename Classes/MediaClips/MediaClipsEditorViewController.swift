//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

protocol MediaClipsEditorDelegate: class {
    /// Callback for when a clip is deleted
    ///
    /// - Parameter index: the index of the deleted clip
    func mediaClipWasDeleted(at index: Int)
    
    /// Callback for when a clip is added
    ///
    /// - Parameter index: index of the newly added clip
    func mediaClipWasAdded(at index: Int)
    
    /// Callback for when a clip starts moving inside the collection
    func mediaClipStartedMoving()
    
    /// Callback for when a clip finishes moving inside the collection
    func mediaClipFinishedMoving()
    
    /// Callback for when a clip is moved inside the collection
    ///
    /// - Parameters:
    ///   - originIndex: Index where the clip was at before the moving around action
    ///   - destinationIndex: Index where the clips is ar after the moving around action
    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int)
}

/// Controller for handling media clips edition (showing, adding, removing, etc)
final class MediaClipsEditorViewController: UIViewController, MediaClipsCollectionControllerDelegate, MediaClipsEditorViewDelegate {
    weak var delegate: MediaClipsEditorDelegate?

    private lazy var editorView: MediaClipsEditorView = {
        let view = MediaClipsEditorView()
        view.delegate = self
        return view
    }()
    private lazy var collectionController: MediaClipsCollectionController = {
        let controller = MediaClipsCollectionController()
        controller.delegate = self
        return controller
    }()

    /// Is there any clip?
    /// This needs to be dynamic because it will be observed
    @objc private(set) dynamic var hasClips: Bool = false

    /// Check if there is a clip selected
    /// This needs to be dynamic because it will be observed
    @objc private(set) dynamic var clipIsSelected: Bool = false

    init() {
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
        view = editorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        load(childViewController: collectionController, into: editorView.collectionContainer)
    }

    // MARK: - Public interface

    /// Adds a new clip
    ///
    /// - Parameter clip: The new MediaClip to add
    func addNewClip(_ clip: MediaClip) {
        collectionController.addNewClip(clip)
        hasClips = true
        clipIsSelected = false
        delegate?.mediaClipWasAdded(at: collectionController.getClips().count - 1)
    }

    /// Undoes the last clip added
    func undo() {
        editorView.hideTrash()
        collectionController.removeLastClip()
        hasClips = collectionController.getClips().count > 0
        clipIsSelected = false
    }
    
    /// Deletes the clip selected on the current dragging session
    func removeDraggingClip() {
        if let index = collectionController.removeDraggingClip() {
            delegate?.mediaClipWasDeleted(at: index)
        }
        else {
            assertionFailure("Clip was dropped but there is nothing to delete")
        }
        hasClips = collectionController.getClips().count > 0
        clipIsSelected = false
    }
    
    /// Returns the image from the last clip of the collection
    func getPreviewFromLastClip() -> UIImage? {
        return collectionController.getPreviewFromLastClip()
    }

    // MARK: - MediaClipsControllerDelegate
    func mediaClipStartedMoving() {
        delegate?.mediaClipStartedMoving()
    }
    
    func mediaClipFinishedMoving() {
        delegate?.mediaClipFinishedMoving()
    }

    func mediaClipWasSelected(at index: Int) {
        editorView.showTrash()
        clipIsSelected = true
    }

    func mediaClipWasDeselected(at index: Int) {
        editorView.hideTrash()
        clipIsSelected = false
    }

    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int) {
        delegate?.mediaClipWasMoved(from: originIndex, to: destinationIndex)
    }
    
    func mediaClipWasSwipedAndDeleted(at index: Int) {
        hasClips = collectionController.getClips().count > 0
        delegate?.mediaClipWasDeleted(at: index)
    }
    
    // MARK: - MediaClipsEditorViewDelegate
    func trashButtonWasPressed() {
        if let index = collectionController.removeSelectedClip() {
            editorView.hideTrash()
            delegate?.mediaClipWasDeleted(at: index)
        }
        else {
            assertionFailure("Trash was pressed when there is nothing selected to delete")
        }
        hasClips = collectionController.getClips().count > 0
        editorView.hideTrash()
        clipIsSelected = false
    }

}
