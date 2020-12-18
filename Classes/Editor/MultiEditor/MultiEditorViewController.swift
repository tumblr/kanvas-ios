import Foundation

protocol MultiEditorComposerDelegate: class {
    func didFinishExporting(media: [Result<EditorViewController.ExportResult, Error>])
    func addButtonWasPressed(clips: [MediaClip])
    func editor(segment: CameraSegment, views: [View]?, canvas: MovableViewCanvas?, drawingView: IgnoreTouchesView?) -> EditorViewController
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
        let edit: Edit?
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
                try! archive(index: old)//migratedIndex ?? old)
            }
            if let new = newValue { // If the new index is the same as the old just keep the current editor
                loadEditor(for: new)
            } else {
                currentEditor = nil
            }
        }
    }

    func addSegment(_ segment: CameraSegment) {

//        let newEditor = editor(for: segment)

        frames.append(Frame(segment: segment, edit: nil))

        let clip = MediaClip(representativeFrame: segment.lastFrame,
                                                        overlayText: nil,
                                                        lastFrame: segment.lastFrame)
        
        clipsController.addNewClip(clip)
        
        selected = clipsController.getClips().indices.last
    }
    
    private let settings: CameraSettings
    private let assetsHandler: AssetsHandlerType
    private let exporterClass: MediaExporting.Type
    private let gifEncoderClass: GIFEncoder.Type
    private let cameraMode: CameraMode?
    private let stickerProvider: StickerProvider?
    private let analyticsProvider: KanvasCameraAnalyticsProvider?
    private let quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?

//    private var edits: [[View]] = []

    struct Edit {
        let data: Data?
        let canvasView: IgnoreTouchesView?
        let options: EditOptions
    }

    private var exportingEditors: [EditorViewController]?

    private weak var currentEditor: EditorViewController?

    init(settings: CameraSettings,
         segments: [CameraSegment],
         assetsHandler: AssetsHandlerType,
         exporterClass: MediaExporting.Type,
         gifEncoderClass: GIFEncoder.Type,
         cameraMode: CameraMode?,
         stickerProvider: StickerProvider?,
         analyticsProvider: KanvasCameraAnalyticsProvider?,
         quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?,
         delegate: MultiEditorComposerDelegate,
         selected: Array<CameraSegment>.Index?,
         edits: [Data?]?) {
        
        self.settings = settings
        self.assetsHandler = assetsHandler
        self.exporterClass = exporterClass
        self.gifEncoderClass = gifEncoderClass
        self.cameraMode = cameraMode
        self.stickerProvider = stickerProvider
        self.analyticsProvider = analyticsProvider
        self.quickBlogSelectorCoordinator = quickBlogSelectorCoordinator
        self.delegate = delegate

        if let edits = edits {
            frames = zip(segments, edits).map { (segment, data) in
                return Frame(segment: segment, edit: Edit(data: data, canvasView: nil, options: EditOptions(soundEnabled: true)))
            }
        } else {
            frames = segments.map({ segment in
                return Frame(segment: segment, edit: nil)
            })
        }

        exportHandler = MultiEditorExportHandler({ [weak delegate] result in
            delegate?.didFinishExporting(media: result)
//            self?.exportingEditors = nil
        })
        self.selected = selected
        super.init(nibName: nil, bundle: nil)
        let clips = segments.map { segment in
            return MediaClip(representativeFrame: segment.lastFrame,
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
//            load(childViewController: editors[selectedIndex], into: editorContainer)
        }
    }

    func loadEditor(for index: Int) {
//        let edit = edits.indices ~= index ? edits[index] : nil
        let views = edits(for: index)
        if let editor = delegate?.editor(segment: frames[index].segment, views: nil, canvas: views?.0, drawingView: views?.1) {
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
            editor.editorView.movableViewCanvas.trashCompletion = { [weak self] in
                self?.clipsController.removeDraggingClip()
            }
            unarchive(editor: editor, index: index)
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
//            editorContainer.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: clipsContainer.topAnchor)
        ])
    }
    
    func deleteAllSegments() {
        clipsController.replace(clips: [])
    }
}

extension MultiEditorViewController: MediaPlayerController {
    func onPostingOptionsDismissed() {
        
    }
}

extension MultiEditorViewController: MediaClipsEditorDelegate {
    func mediaClipWasDeleted(at index: Int) {
        var clips = self.clipsController.getClips()

        if frames.indices.contains(index) {
            frames.remove(at: index)
        }

        migratedIndex = shift(index: selected ?? 0, indices: [index], edits: frames)
        selected = newIndex(indices: [index], selected: selected, edits: frames)
        if selected == nil {
            dismissButtonPressed()
        }
        //TODO: Ask delegate for view controller to load
//        else {
//            let previousIndex = editors.index(before: index)
//            if editors.indices.contains(previousIndex) {
//                viewControllerToLoad = editors[previousIndex]
//            }
//            else {
//                dismiss(animated: true, completion: nil)
//                return
//            }
//        }
//        load(childViewController: viewControllerToLoad, into: editorContainer)
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

    func mediaClipStartedMoving() {
        currentEditor?.editorView.updateUI(forDraggingClip: true)
    }
    
    func mediaClipFinishedMoving() {
        currentEditor?.editorView.updateUI(forDraggingClip: false)
    }
    
    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int) {
        if let selected = selected {
            try! archive(index: selected)
        }
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
    
    func addButtonWasPressed(clips: [MediaClip]) {
        delegate?.addButtonWasPressed(clips: clips)
//        dismiss(animated: true, completion: nil)
    }
}

extension MultiEditorViewController: EditorControllerDelegate {
    func didFinishExportingVideo(url: URL?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {
    }
    
    func didFinishExportingImage(image: UIImage?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {
//        if let image = image {
//            var clips = clipsController.getClips()
//            if let selected = selected {
//                let selectedClip = editors.distance(from: editors.startIndex, to: selected)
//                clips[selectedClip] = MediaClip(representativeFrame: image, overlayText: nil, lastFrame: image)
//            }
//            clipsController.replace(clips: clips)
//        }
    }
    
    func didFinishExportingFrames(url: URL?, size: CGSize?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {
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

    struct EditOptions {
        let soundEnabled: Bool
    }

    func archive(index: Int) throws {
        guard let currentEditor = currentEditor else {
            return
        }
        let currentCanvas = try NSKeyedArchiver.archivedData(withRootObject: currentEditor.editorView.movableViewCanvas, requiringSecureCoding: true)
        let drawingLayer = currentEditor.editorView.drawingCanvas
        let options = EditOptions(soundEnabled: currentEditor.shouldExportSound ?? true)
        if frames.indices ~= index {
            let frame = frames[index]
            frames[index] = Frame(segment: frame.segment, edit: Edit(data: currentCanvas, canvasView: drawingLayer, options: options))
        } else {
            print("Invalid frame index")
//            edits.insert((currentCanvas, drawingLayer, options), at: min(index, edits.endIndex))
        }
    }

    func edits(for index: Int) -> (MovableViewCanvas?, IgnoreTouchesView?, EditOptions)? {
        if frames.indices ~= index, let edit = frames[index].edit {
            let canvas: MovableViewCanvas?
            if let edit = edit.data {
                canvas = try! NSKeyedUnarchiver.unarchivedObject(ofClass: MovableViewCanvas.self, from: edit)
            } else {
                canvas = nil
            }
            let drawing = edit.canvasView
            let options = edit.options
            return (canvas, drawing, options)
        } else {
            return nil
        }
    }

    func unarchive(editor: EditorViewController, index: Int) {
        if frames.indices ~= index {
            let canvas: MovableViewCanvas?
            let drawing: IgnoreTouchesView?
            if let edits = edits(for: index) {
                canvas = edits.0
                drawing = edits.1
            } else {
                canvas = nil
                drawing = nil
            }

            canvas?.delegate = editor.editorView
        }
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
            try! archive(index: selected)
        }

        exportHandler.startWaiting(for: frames.count)

        guard let delegate = delegate else { return true }

        frames.enumerated().forEach({ (idx, frame) in
//            let semaphore = DispatchSemaphore(value: 1)
            autoreleasepool {
                let canvas: MovableViewCanvas?
                if let edit = frame.edit?.data {
                    canvas = try! NSKeyedUnarchiver.unarchivedObject(ofClass: MovableViewCanvas.self, from: edit)
                } else {
                    canvas = nil
                }
                let editor = delegate.editor(segment: frame.segment, views: nil, canvas: canvas, drawingView: frame.edit?.canvasView)
                editor.shouldExportSound = frame.edit?.options.soundEnabled ?? true

                unarchive(editor: editor, index: idx)
                editor.export { [weak self] result in
//                    semaphore.signal()
                    self?.exportHandler.handleExport(result, for: idx)
                }
            }
//            semaphore.wait()
        })
        return false
    }

    func archive(editor: EditorViewController) {
        
    }
    
    func addButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}
