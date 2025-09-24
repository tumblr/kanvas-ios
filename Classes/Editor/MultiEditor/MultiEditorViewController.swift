//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import os
import UIKit

protocol MultiEditorComposerDelegate: EditorControllerDelegate {
    func didFinishExporting(media: [Result<EditorViewController.ExportResult, Error>])
    func addButtonWasPressed()
    func editor(segment: CameraSegment, edit: EditorViewController.Edit?) -> EditorViewController
    func dismissButtonPressed()
}

class MultiEditorViewController: UIViewController {
    private lazy var clipsController: MediaClipsEditorViewController = {
        let collectionViewSettings = MediaClipsCollectionView.Settings(showsFadeOutGradient: false)
        let collectionSettings = MediaClipsCollectionController.Settings(clipsCollectionViewSettings: collectionViewSettings)
        let clipsEditor = MediaClipsEditorViewController(showsAddButton: true, collectionSettings: collectionSettings)
        clipsEditor.delegate = self
        clipsEditor.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return clipsEditor
    }()
    
    private let clipsContainer = IgnoreTouchesView()
    private let editorContainer = IgnoreTouchesView()
    
    private let exportHandler: MultiEditorExportHandler
    
    private weak var delegate: MultiEditorComposerDelegate?

    struct Frame {
        let segment: CameraSegment
        let edit: EditorViewController.Edit?
    }

    private var frames: [Frame]

    var migratedIndex: Int?
    var selected: Int? {
        willSet {
            defer {
                migratedIndex = nil
            }
            if let selected = newValue {
                clipsController.select(index: selected)
            }
            guard newValue != selected && migratedIndex != newValue else {
                return
            }
            if let old = selected {
                archive(index: old)
            }
            if let new = newValue { // If the new index is the same as the old just keep the current editor
                loadEditor(for: new)
            } else {
                currentEditor = nil
            }
        }
    }

    func addSegment(_ segment: CameraSegment) {

        frames.append(Frame(segment: segment, edit: nil))

        let clip = MediaClip(representativeFrame: segment.lastFrame,
                                                        overlayText: nil,
                                                        lastFrame: segment.lastFrame)
        
        clipsController.addNewClip(clip)
        
        selected = clipsController.getClips().indices.last
    }
    
    private let settings: CameraSettings

    private var exportingEditors: [EditorViewController]?

    private(set) weak var currentEditor: EditorViewController?

    init(settings: CameraSettings,
         frames: [Frame],
         delegate: MultiEditorComposerDelegate,
         selected: Array<CameraSegment>.Index?) {
        
        self.settings = settings
        self.delegate = delegate
        self.frames = frames

        self.exportHandler = MultiEditorExportHandler({ [weak delegate] result in
            delegate?.didFinishExporting(media: result)
        })
        self.selected = selected
        super.init(nibName: nil, bundle: nil)
        let clips = frames.map { frame in
            return MediaClip(representativeFrame:
                                frame.segment.lastFrame,
                                                            overlayText: nil,
                                                            lastFrame: frame.segment.lastFrame)
        }
        clipsController.replace(clips: clips)
    }

    @available(*, unavailable, message: "use init() instead")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        setupContainers()
        load(childViewController: clipsController, into: clipsContainer)
        if let selectedIndex = selected {
            loadEditor(for: selectedIndex)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clipsController.select(index: selected ?? 0)
    }

    func loadEditor(for index: Int, current: Bool = true) {
        let frame = frames[index]
        if let editor = delegate?.editor(segment: frame.segment, edit: frame.edit) {
            if current {
                currentEditor?.stopPlayback()
                currentEditor?.unloadFromParentViewController()
            }
            let additionalPadding: CGFloat = 10 // Extra padding for devices that don't have safe areas (which provide some padding by default).
            let bottom: CGFloat
            if view.safeAreaInsets.bottom > 0 {
                bottom = MediaClipsCollectionView.height + 10
            } else {
                bottom = MediaClipsCollectionView.height + 10 + additionalPadding
            }
            editor.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
            editor.delegate = self
            editor.editorView.movableViewCanvas.trashCompletion = { [weak self] in
                self?.clipsController.removeDraggingClip()
            }
            load(childViewController: editor, into: editorContainer)
            if current {
                currentEditor = editor
            } else {
                editor.view.alpha = 0.0
            }
        }
    }
        
    func setupContainers() {
        clipsContainer.backgroundColor = .clear
        clipsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clipsContainer)

        NSLayoutConstraint.activate([
            clipsContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            clipsContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            clipsContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            clipsContainer.heightAnchor.constraint(equalToConstant: MediaClipsEditorView.height)
        ])

        editorContainer.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(editorContainer, belowSubview: clipsContainer)
        
        NSLayoutConstraint.activate([
            editorContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            editorContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            editorContainer.topAnchor.constraint(equalTo: view.topAnchor),
            editorContainer.bottomAnchor.constraint(equalTo: clipsContainer.bottomAnchor),
        ])
    }
    
    func deleteAllSegments() {
        clipsController.replace(clips: [])
    }
}

extension MultiEditorViewController: MediaPlayerController {
    func onQuickPostButtonSubmitted() {

    }

    func onQuickPostOptionsShown(visible: Bool, hintText: String?, view: UIView) {

    }

    func onQuickPostOptionsSelected(selected: Bool, hintText: String?, view: UIView) {
        
    }

    func onPostingOptionsDismissed() {
        
    }
}

extension MultiEditorViewController: MediaClipsEditorDelegate {
    func mediaClipStartedMoving() {
        currentEditor?.editorView.updateUI(forDraggingClip: true)
    }

    func mediaClipFinishedMoving() {
        currentEditor?.editorView.updateUI(forDraggingClip: false)
    }
    
    func addButtonWasPressed() {
        delegate?.addButtonWasPressed()
    }

    func mediaClipWasDeleted(at index: Int) {
        if frames.indices.contains(index) {
            frames.remove(at: index)
        }

        let newSelection = newIndex(indices: [index], selected: selected, edits: frames)
        if newSelection == selected {
            selected = nil
        }
        selected = newSelection
        if selected == nil {
            dismissButtonPressed()
        }
        
        /// The editor does not layout automatically after we delete a clip and load another image
        editorContainer.layoutIfNeeded()
    }
    
    func mediaClipWasAdded(at index: Int) {

    }

    func newIndex(indices: [Int], selected: Int?, edits: [Any]) -> Int? {
        var nextIndex: Int? = nil

        let sortedindices = indices.sorted()

        if let selected = selected, sortedindices.contains(selected) { // If the selection is contained in the set
            if let index = indices.first, edits.indices.contains(index) { // Keep the same selection if it still exists.
                return index
            } else if let firstIndex = indices.first, firstIndex > edits.startIndex { // Item before if it does not.
                nextIndex = edits.index(before: firstIndex)
            } else if let lastIndex = sortedindices.last, lastIndex < edits.endIndex { // Item after if prior item doesn't exist.
                nextIndex = edits.index(after: lastIndex)
            }
        } else {
            return shift(index: selected ?? 0, indices: indices, edits: edits)
        }

        return nextIndex
    }

    func shift(index: Int, indices: [Int], edits: [Any]) -> Int {
        if index < indices.first ?? 0 {
            return index
        } else {
            let countToIndex = indices.filter({ $0 < selected ?? 0 })
            return edits.index(selected ?? 0, offsetBy: -countToIndex.count)
        }
    }

    func shift(index: Int, moves: [(origin: Int, destination: Int)], edits: [Any]) -> Int {
        let indexMoves: [Int] = moves.map { origin, destination -> Int in
            if (index < origin && index < destination) || (index > origin && index > destination) {
                return 0
            } else {
                if destination >= index && origin < index {
                    return -1
                } else if destination <= index && origin > index {
                    return 1
                } else {
                    return 0
                }
            }
        }
        return index + indexMoves.reduce(0, { $0 + $1 })
    }

    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int) {
        if let selected = selected {
            archive(index: selected)
        }
        frames.move(from: originIndex, to: destinationIndex)

        let selectedIndex: Int
        if selected == originIndex {
            // When moving the selected frame just move it to the destination index
            selectedIndex = destinationIndex
        } else {
            // Otherwise calculate the shifted index value
            selectedIndex = shift(index: selected ?? 0, moves: [(originIndex, destinationIndex)], edits: frames)
        }

        migratedIndex = selectedIndex
        selected = selectedIndex
    }
    
    func mediaClipWasSelected(at: Int) {
        selected = at
    }
    
    @objc func nextButtonWasPressed() {
    }
}

extension MultiEditorViewController: EditorControllerDelegate {
    func editorDidAppear() {
        delegate?.editorDidAppear()
    }

    func editorWillDisappear() {
        delegate?.editorWillDisappear()
    }

    func getBlogSwitcher() -> UIView {
        return UIView()
    }

    func getQuickPostButton() -> UIView {
        return UIView()
    }

    func didFinishExportingVideo(url: URL?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {
        // Handled by MultiEditorExportHandler
    }
    
    func didFinishExportingImage(image: UIImage?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {
        // Handled by MultiEditorExportHandler
    }
    
    func didFinishExportingFrames(url: URL?, size: CGSize?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {
        // Handled by MultiEditorExportHandler
    }

    func didFailExporting() {
        // Handled by MultiEditorExportHandler
    }
    
    func dismissButtonPressed() {
        delegate?.dismissButtonPressed()
    }
    
    func didDismissColorSelectorTooltip() {
        
    }
    
    func editorShouldShowColorSelectorTooltip() -> Bool {
        return true
    }
    
    func didEndStrokeSelectorAnimation() {
        
    }
    
    func editorShouldShowStrokeSelectorAnimation() -> Bool {
        return true
    }
    
    func tagButtonPressed() {
        
    }

    func showLoading() {
        currentEditor?.showLoading()
        clipsContainer.alpha = 0.5
        clipsContainer.isUserInteractionEnabled = false
    }

    func hideLoading() {
        currentEditor?.hideLoading()
        clipsContainer.alpha = 1.0
        clipsContainer.isUserInteractionEnabled = true
    }

    // This overrides the export behavior of the EditorViewControllers.
    func shouldExport() -> Bool {

        showLoading()

        if let selected = selected {
            archive(index: selected)
        }

        exportHandler.startWaiting(for: frames.count)

        guard let delegate = delegate else { return true }

        frames.enumerated().forEach({ (idx, frame) in
            autoreleasepool {
                let editor = delegate.editor(segment: frame.segment, edit: frame.edit)
                editor.export { [weak self, editor] result in
                    let _ = editor // strong reference until the export completes
                    self?.exportHandler.handleExport(result, for: idx)
                }
            }
        })

        if let selected = self.selected {
            loadEditor(for: selected, current: true)
        }

        return false
    }

    func addButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: Edit + Archive

private let archive_log = OSLog(subsystem: "com.tumblr.kanvas", category: "MultiEditorArchive")

extension MultiEditorViewController {
    func archive(index: Int) {
        guard let currentEditor = currentEditor else {
            return
        }

        if frames.indices ~= index {
            let frame = frames[index]
            frames[index] = Frame(segment: frame.segment, edit: currentEditor.edit)
        } else {
            os_log("Invalid frame index on archive", log: archive_log, type: .debug)
        }
    }
}
