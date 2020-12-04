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

    private var segments: [CameraSegment]

    var migratedIndex: Int?
    var selected: Int? {
        willSet {
            guard newValue != selected && migratedIndex != newValue else {
                return
            }
            if let old = selected {
                try! archive(index: migratedIndex ?? old)
                migratedIndex = nil
            }
            if let new = newValue { // If the new index is the same as the old just keep the current editor
                loadEditor(for: new)
            } else {
                dismissButtonPressed()
            }
        }
    }

    func addSegment(_ segment: CameraSegment) {

//        let newEditor = editor(for: segment)

        segments.append(segment)

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

    private var edits: [(Data?, IgnoreTouchesView?, EditOptions)] = []
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
         edits: [Data]?) {
        
        self.settings = settings
        self.segments = segments
        self.assetsHandler = assetsHandler
        self.exporterClass = exporterClass
        self.gifEncoderClass = gifEncoderClass
        self.cameraMode = cameraMode
        self.stickerProvider = stickerProvider
        self.analyticsProvider = analyticsProvider
        self.quickBlogSelectorCoordinator = quickBlogSelectorCoordinator
        self.delegate = delegate

        if let edits = edits {
            self.edits = edits.map({ data in
                return (data, nil, EditOptions(soundEnabled: true))
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
        if let editor = delegate?.editor(segment: segments[index], views: nil, canvas: views?.0, drawingView: views?.1) {
            currentEditor?.stopPlayback()
            currentEditor?.unloadFromParentViewController()
            editor.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: MediaClipsCollectionView.height + 10, right: 0)
            editor.delegate = self
            editor.editorView.movableViewCanvas.trashCompletion = { [weak self] in
                self?.clipsController.removeDraggingClip()
            }
//            unarchive(editor: editor, index: index)
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
        if edits.indices.contains(index) {
            edits.remove(at: index)
        }
        if segments.indices.contains(index) {
            segments.remove(at: index)
        }

        migratedIndex = shift(index: selected ?? 0, indices: [index], edits: edits)
        selected = newIndex(indices: [index], selected: selected, edits: edits)
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

        if let selected = selected, sortedindices.contains(selected) { // If selected index hasn't been deleted don't change it
            if let firstIndex = indices.first, firstIndex > edits.startIndex {
                nextIndex = edits.index(before: firstIndex)
            } else if let lastIndex = sortedindices.last, lastIndex > edits.startIndex {
                nextIndex = edits.index(before: lastIndex)
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
        if let index = selected {
            try! archive(index: index)
        }
        segments.move(from: originIndex, to: destinationIndex)
        edits.move(from: originIndex, to: destinationIndex)
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
        if edits.indices ~= index {
            edits[index] = (currentCanvas, drawingLayer, options)
        } else {
            edits.insert((currentCanvas, drawingLayer, options), at: index)
        }
    }

    func edits(for index: Int) -> (MovableViewCanvas?, IgnoreTouchesView?, EditOptions)? {
        if edits.indices ~= index {
            let edit = edits[index] 
            let canvas: MovableViewCanvas?
            if let edit = edit.0 {
                canvas = try! NSKeyedUnarchiver.unarchivedObject(ofClass: MovableViewCanvas.self, from: edit)
            } else {
                canvas = nil
            }
            let drawing = edit.1
            let options = edit.2
            return (canvas, drawing, options)
        } else {
            return nil
        }
    }

    func unarchive(editor: EditorViewController, index: Int) {
        if edits.indices ~= index {
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
    }

    func hideLoading() {
        currentEditor?.hideLoading()
    }

    // This overrides the export behavior of the EditorViewControllers.
    func shouldExport() -> Bool {

        showLoading()

        if let selected = selected {
            try! archive(index: selected)
        }

        exportHandler.startWaiting(for: segments.count)
        exportingEditors = segments.enumerated().compactMap { (idx, segment) in
            let edits = self.edits(for: idx)
            let editor = delegate?.editor(segment: segment, views: nil, canvas: edits?.0, drawingView: edits?.1)
            editor?.shouldExportSound = edits?.2.soundEnabled ?? true
            return editor
        }
        exportingEditors?.enumerated().forEach { (idx, editor) in
            unarchive(editor: editor, index: idx)
            editor.export { [weak self] result in
                self?.exportHandler.handleExport(result, for: idx)
            }
        }
        return false
    }

    func archive(editor: EditorViewController) {
        
    }
    
    func addButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
}
