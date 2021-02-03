import Foundation

protocol MultiEditorComposerDelegate: EditorControllerDelegate {
    func didFinishExporting(media: [Result<EditorViewController.ExportResult, Error>])
    func addButtonWasPressed()
    func editor(segment: CameraSegment) -> EditorViewController
    func dismissButtonPressed()
}

class MultiEditorViewController: UIViewController {
    private lazy var clipsController: MediaClipsEditorViewController = {
        let clipsEditor = MediaClipsEditorViewController(showsAddButton: true)
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
            if let new = newValue { // If the new index is the same as the old just keep the current editor
                loadEditor(for: new)
            } else {
                currentEditor = nil
            }
        }
    }

    func addSegment(_ segment: CameraSegment) {
        frames.append(Frame(segment: segment))

        let clip = MediaClip(representativeFrame: segment.lastFrame,
                                                        overlayText: nil,
                                                        lastFrame: segment.lastFrame)
        
        clipsController.addNewClip(clip)
        
        selected = clipsController.getClips().indices.last
    }
    
    private let settings: CameraSettings


    private var exportingEditors: [EditorViewController]?

    private weak var currentEditor: EditorViewController?

    init(settings: CameraSettings,
         segments: [CameraSegment],
         delegate: MultiEditorComposerDelegate,
         selected: Array<CameraSegment>.Index?) {
        
        self.settings = settings
        self.delegate = delegate

        frames = segments.map({ segment in
            return Frame(segment: segment)
        })

        self.exportHandler = MultiEditorExportHandler({ [weak delegate] result in
            delegate?.didFinishExporting(media: result)
//            self?.exportingEditors = nil
        })
        self.selected = selected
        super.init(nibName: nil, bundle: nil)
        let clips = segments.map { segment in
            return MediaClip(representativeFrame:
                                segment.lastFrame,
                                                            overlayText: nil,
                                                            lastFrame: segment.lastFrame)
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

    func loadEditor(for index: Int) {
        if let editor = delegate?.editor(segment: frames[index].segment) {
            currentEditor?.stopPlayback()
            currentEditor?.unloadFromParentViewController()
            let additionalPadding: CGFloat = 10 // Extra padding for devices that don't have safe areas (which provide some padding by default).
            let bottom: CGFloat
            if view.safeAreaInsets.bottom > 0 {
                bottom = MediaClipsCollectionView.height + 10
            } else {
                bottom = MediaClipsCollectionView.height + 10 + additionalPadding
            }
            editor.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
            editor.delegate = self
            load(childViewController: editor, into: editorContainer)
            currentEditor = editor
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
        // No-op for the moment. UI is coming in a future commit.
    }

    func mediaClipFinishedMoving() {
        // No-op for the moment. UI is coming in a future commit.
    }
    
    func addButtonWasPressed() {
        delegate?.addButtonWasPressed()
    }

    func mediaClipWasDeleted(at index: Int) {
        if frames.indices.contains(index) {
            frames.remove(at: index)
        }

        migratedIndex = shift(index: selected ?? 0, indices: [index], edits: frames)
        selected = newIndex(indices: [index], selected: selected, edits: frames)
        if selected == nil {
            dismissButtonPressed()
        }
    }
    
    func mediaClipWasAdded(at index: Int) {

    }

    func newIndex(indices: [Int], selected: Int?, edits: [Any]) -> Int? {
        var nextIndex: Int? = nil

        let sortedindices = indices.sorted()

        if let selected = selected, sortedindices.contains(selected) {
            if let index = indices.first, edits.indices.contains(index) {
                return index
            } else if let firstIndex = indices.first, firstIndex > edits.startIndex {
                nextIndex = edits.index(before: firstIndex)
            } else if let lastIndex = sortedindices.last, lastIndex < edits.endIndex {
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

    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int) {
        frames.move(from: originIndex, to: destinationIndex)

        let newIndex: Int
        if selected == originIndex {
            // When moving the selected frame just move it to the destination index
            newIndex = destinationIndex
        } else {
            // Otherwise calculate the shifted index value
            newIndex = shift(index: selected ?? 0, indices: [originIndex], edits: frames)
        }

        migratedIndex = newIndex
        selected = newIndex
    }
    
    func mediaClipWasSelected(at: Int) {
        selected = at
    }
    
    @objc func nextButtonWasPressed() {
    }    
}

extension MultiEditorViewController: EditorControllerDelegate {

    func getBlogSwitcher() -> UIView {
        return UIView()
    }

    func getQuickPostButton() -> UIView {
        return UIView()
    }

    func didFinishExportingVideo(url: URL?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool) {
        // No-op for the moment. API is coming in future commit.
    }
    
    func didFinishExportingImage(image: UIImage?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool) {
        // No-op for the moment. API is coming in future commit.
    }
    
    func didFinishExportingFrames(url: URL?, size: CGSize?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool) {
        // No-op for the moment. API is coming in future commit.
    }
    
    func dismissButtonPressed() {
        delegate?.dismissButtonPressed()
    }
    
    func didDismissColorSelectorTooltip() {
        delegate?.didDismissColorSelectorTooltip()
    }
    
    func editorShouldShowColorSelectorTooltip() -> Bool {
        return delegate?.editorShouldShowColorSelectorTooltip() == true
    }
    
    func didEndStrokeSelectorAnimation() {
        delegate?.didEndStrokeSelectorAnimation()
    }
    
    func editorShouldShowStrokeSelectorAnimation() -> Bool {
        return delegate?.editorShouldShowStrokeSelectorAnimation() == true
    }
    
    func tagButtonPressed() {
        delegate?.tagButtonPressed()
    }

    struct EditOptions {
        let soundEnabled: Bool
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

        exportHandler.startWaiting(for: frames.count)

        guard let delegate = delegate else { return true }

        frames.enumerated().forEach({ (idx, frame) in
            autoreleasepool {
                let editor = delegate.editor(segment: frame.segment)
                editor.export { [weak self, editor] result in
                    let _ = editor // strong reference until the export completes
                    self?.exportHandler.handleExport(result, for: idx)
                }
            }
        })
        return false
    }
}
