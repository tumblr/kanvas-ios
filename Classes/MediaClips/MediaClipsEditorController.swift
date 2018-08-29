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
}

/// Controller for handling media clips edition (showing, adding, removing, etc)
final class MediaClipsEditorController: UIViewController, MediaClipsCollectionControllerDelegate, MediaClipsEditorViewDelegate {
    weak var delegate: MediaClipsEditorDelegate?

    private lazy var _view: MediaClipsEditorView = {
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
    @objc private(set) dynamic var hasClips: Bool = false

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
        view = _view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        load(childViewController: collectionController, into: _view.collectionContainer)
    }

    // MARK: - Public interface

    /// Adds a new clip
    ///
    /// - Parameter clip: The new MediaClip to add
    func addNewClip(_ clip: MediaClip) {
        collectionController.addNewClip(clip)
        hasClips = true
        clipIsSelected = false
    }

    /// Undoes the last clip added
    func undo() {
        _view.hideTrash()
        collectionController.removeLastClip()
        hasClips = collectionController.getClips().count > 0
        clipIsSelected = false
    }

    // MARK: - MediaClipsControllerDelegate
    func mediaClipWasSelected(at index: Int) {
        _view.showTrash()
        clipIsSelected = true
    }

    func mediaClipWasDeselected(at index: Int) {
        _view.hideTrash()
        clipIsSelected = false
    }

    // MARK: - MediaClipsEditorViewDelegate
    func trashButtonWasPressed() {
        if let index = collectionController.removeSelectedClip() {
            _view.hideTrash()
            delegate?.mediaClipWasDeleted(at: index)
        }
        else {
            assertionFailure("Trash was pressed when there is nothing selected to delete")
        }
        hasClips = collectionController.getClips().count > 0
        _view.hideTrash()
        clipIsSelected = false
    }

}
