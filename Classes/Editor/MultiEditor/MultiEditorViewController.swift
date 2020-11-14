import Foundation

protocol MultiEditorComposerDelegate: class {
    func didFinishExporting(media: [Result<(UIImage?, URL?, MediaInfo), Error>])
    func addButtonWasPressed(clips: [MediaClip])
    func editor(segment: CameraSegment, views: [View]?, canvas: MovableViewCanvas?, drawingView: IgnoreTouchesView?) -> EditorViewController
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

    var selected: Int? {
        willSet {
            guard newValue != selected else { return }
            if let old = selected {
                archive(index: old)
            }
            if let new = newValue {
                loadEditor(for: new)
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
         selected: Array<CameraSegment>.Index?) {
        
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
    
    func mediaClipStartedMoving() {
    }
    
    func mediaClipFinishedMoving() {
        
    }
    
    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int) {
        if let index = selected {
            archive(index: index)
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
    func didFinishExportingVideo(url: URL?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool) {
    }
    
    func didFinishExportingImage(image: UIImage?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool) {
//        if let image = image {
//            var clips = clipsController.getClips()
//            if let selected = selected {
//                let selectedClip = editors.distance(from: editors.startIndex, to: selected)
//                clips[selectedClip] = MediaClip(representativeFrame: image, overlayText: nil, lastFrame: image)
//            }
//            clipsController.replace(clips: clips)
//        }
    }
    
    func didFinishExportingFrames(url: URL?, size: CGSize?, info: MediaInfo?, action: KanvasExportAction, mediaChanged: Bool) {
    }
    
    func dismissButtonPressed() {
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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

    func archive(index: Int) {
        let currentCanvas = try! NSKeyedArchiver.archivedData(withRootObject: currentEditor!.editorView.movableViewCanvas, requiringSecureCoding: true)
//        let encoder = JSONEncoder()
//        let currentCanvas = try! encoder.encode(currentEditor!.editorView.movableViewCanvas)
        let drawingLayer = currentEditor?.editorView.drawingCanvas
        let options = EditOptions(soundEnabled: currentEditor?.shouldExportSound ?? true)
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
//                let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: edit)
//                unarchiver.requiresSecureCoding = false
//                canvas = unarchiver.decodeObject(of: MovableViewCanvas.self, forKey: NSKeyedArchiveRootObjectKey)
//                let decoder = JSONDecoder()
//                canvas = try! decoder.decode(MovableViewCanvas.self, from: edit)
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

    // This overrides the export behavior of the EditorViewControllers.
    func shouldExport() -> Bool {

        if let selected = selected {
            archive(index: selected)
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
