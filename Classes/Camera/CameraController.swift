//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

// Media wrapper for media generated from the CameraController
public struct KanvasMedia {
    public let unmodified: URL?
    public let output: URL
    public let info: MediaInfo
    public let size: CGSize
    public let archive: URL?
    public let type: MediaType

    init(unmodified: URL?,
         output: URL,
         info: MediaInfo,
         size: CGSize,
         archive: URL?,
         type: MediaType) {
        self.unmodified = unmodified
        self.output = output
        self.info = info
        self.size = size
        self.archive = archive
        self.type = type
    }

    init(asset: AVURLAsset, original: URL?, info: MediaInfo, archive: URL?) {
        self.init(unmodified: original,
             output: asset.url,
             info: info,
             size: asset.videoScreenSize ?? .zero,
             archive: archive,
             type: .video
        )
    }

    init(image: UIImage, url: URL, original: URL?, info: MediaInfo, archive: URL?) {
        self.init(unmodified: original,
             output: url,
             info: info,
             size: image.size,
             archive: archive,
             type: .image
        )
    }

    public init(type: MediaType, url: URL, info: MediaInfo, size: CGSize) {
        self.init(unmodified: nil,
                  output: url,
                  info: info,
                  size: size,
                  archive: nil,
                  type: type
        )
    }
}

public enum MediaType {
    case image
    case video
    case frames
}

public enum KanvasExportAction {
    case previewConfirm
    case confirm
    case post
    case save
    case postOptions
    case confirmPostOptions
}

// Error handling
enum CameraControllerError: Swift.Error {
    case exportFailure
    case unknown
}

// Protocol for dismissing CameraController
// or exporting its created media.
public protocol CameraControllerDelegate: class {

    /**
     A function that is called when an image is exported. Can be nil if the export fails
     - parameter media: KanvasMedia - this is the media created in the controller (can be image, video, etc)
     - seealso: enum KanvasMedia
     */
    func didCreateMedia(_ cameraController: CameraController, media: CameraController.MediaOutput, exportAction: KanvasExportAction)

    /**
     A function that is called when the main camera dismiss button is pressed
     */
    func dismissButtonPressed(_ cameraController: CameraController)

    /// Called when the tag button is pressed in the editor
    func tagButtonPressed()

    /// Called when the editor is dismissed
    func editorDismissed(_ cameraController: CameraController)
    
    /// Called after the welcome tooltip is dismissed
    func didDismissWelcomeTooltip()
    
    /// Called to ask if welcome tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func cameraShouldShowWelcomeTooltip() -> Bool
    
    /// Called after the color selector tooltip is dismissed
    func didDismissColorSelectorTooltip()
    
    /// Called to ask if color selector tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func editorShouldShowColorSelectorTooltip() -> Bool
    
    /// Called after the stroke animation has ended
    func didEndStrokeSelectorAnimation()
    
    /// Called to ask if stroke selector animation should be shown
    ///
    /// - Returns: Bool for animation
    func editorShouldShowStrokeSelectorAnimation() -> Bool
    
    /// Called when a drag interaction starts
    func didBeginDragInteraction()
    
    /// Called when a drag interaction ends
    func didEndDragInteraction()

    func openAppSettings(completion: ((Bool) -> ())?)
    
    /// Obtains the quick post button for the editor.
    ///
    /// - Returns: the quick post button.
    func getQuickPostButton() -> UIView
    
    /// Obtains the blog switcher for the editor.
    ///
    /// - Returns: the blog switcher.
    func getBlogSwitcher() -> UIView
}

// A controller that contains and layouts all camera handling views and controllers (mode selector, input, etc).
open class CameraController: UIViewController, MediaClipsEditorDelegate, CameraPreviewControllerDelegate, EditorControllerDelegate, CameraZoomHandlerDelegate, OptionsControllerDelegate, ModeSelectorAndShootControllerDelegate, CameraViewDelegate, CameraInputControllerDelegate, FilterSettingsControllerDelegate, CameraPermissionsViewControllerDelegate, KanvasMediaPickerViewControllerDelegate, MediaPickerThumbnailFetcherDelegate, MultiEditorComposerDelegate {

    public typealias MediaOutput = [Result<KanvasMedia?, Error>]

    enum ArchiveErrors: Error {
        case unknownMedia
    }

    public func hideLoading() {
        multiEditorViewController?.hideLoading()
    }

    /// The delegate for camera callback methods
    public weak var delegate: CameraControllerDelegate?

    private lazy var options: [[Option<CameraOption>]] = {
        return getOptions(from: self.settings)
    }()
    private lazy var cameraView: CameraView = {
        let view = CameraView(settings: self.settings, numberOfOptionRows: CGFloat(options.count))
        view.delegate = self
        return view
    }()
    private lazy var modeAndShootController: ModeSelectorAndShootController = {
        let controller = ModeSelectorAndShootController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    private lazy var topOptionsController: OptionsController<CameraController> = {
        let controller = OptionsController<CameraController>(options: options, spacing: CameraConstants.optionHorizontalMargin, settings: self.settings)
        controller.delegate = self
        return controller
    }()
    private lazy var clipsController: MediaClipsEditorViewController = {
        let controller = MediaClipsEditorViewController(showsAddButton: false)
        controller.delegate = self
        return controller
    }()

    private lazy var cameraInputController: CameraInputController = {
        let controller = CameraInputController(settings: self.settings, recorderClass: self.recorderClass, segmentsHandler: self.segmentsHandler, delegate: self)
        return controller
    }()
    private lazy var imagePreviewController: ImagePreviewController = {
        let controller = ImagePreviewController()
        return controller
    }()
    private lazy var filterSettingsController: FilterSettingsController = {
        let controller = FilterSettingsController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    private lazy var cameraPermissionsViewController: CameraPermissionsViewController = {
        let controller = CameraPermissionsViewController(shouldShowMediaPicker: settings.features.mediaPicking, captureDeviceAuthorizer: self.captureDeviceAuthorizer)
        controller.delegate = self
        return controller
    }()
    private lazy var mediaPickerThumbnailFetcher: MediaPickerThumbnailFetcher = {
        let fetcher = MediaPickerThumbnailFetcher()
        fetcher.delegate = self
        return fetcher
    }()
    private lazy var segmentsHandler: SegmentsHandlerType = {
        return segmentsHandlerClass.init()
    }()
        
    private let settings: CameraSettings
    private let analyticsProvider: KanvasAnalyticsProvider?
    private var currentMode: CameraMode
    private var isRecording: Bool
    private var disposables: [NSKeyValueObservation] = []
    private let stickerProvider: StickerProvider?
    private let cameraZoomHandler: CameraZoomHandler
    private let feedbackGenerator: UINotificationFeedbackGenerator
    private let quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?
    private let tagCollection: UIView?
    private let saveDirectory: URL?

    private let mediaPicker: MediaPicker.Type
    var recorderClass: CameraRecordingProtocol.Type = CameraRecorder.self
    var segmentsHandlerClass: SegmentsHandlerType.Type = CameraSegmentHandler.self
    var captureDeviceAuthorizer: CaptureDeviceAuthorizing = CaptureDeviceAuthorizer()

    private weak var mediaPlayerController: MediaPlayerController?

    /// Constructs a CameraController that will take care of creating media
    /// as the result of user interaction.
    ///
    /// - Parameters:
    ///   - settings: Settings to configure in which ways should the controller interact with the user, which options should the controller give the user and which should be the result of the interaction.
    ///   - mediaPicker: A class providing a Media Picker UI conforming to `MediaPicker`.
    ///   - stickerProvider: An object that will provide the stickers in the editor.
    ///   - analyticsProvider: An object conforming to KanvasCameraAnalyticsProvider used by tracking methods.
    ///   - quickBlogSelectorCoordinator: An object which handles the Quick Blog selection UI.
    ///   - tagCollection: A view to be shown when selecting tags.
    public init(settings: CameraSettings,
            mediaPicker: MediaPicker.Type?,
         stickerProvider: StickerProvider?,
         analyticsProvider: KanvasAnalyticsProvider?,
         quickBlogSelectorCoordinator: KanvasQuickBlogSelectorCoordinating?,
         tagCollection: UIView?,
         saveDirectory: URL?) {
        self.settings = settings
        currentMode = settings.initialMode
        isRecording = false
        self.mediaPicker = mediaPicker ?? KanvasMediaPickerViewController.self
        self.stickerProvider = stickerProvider
        self.analyticsProvider = analyticsProvider
        self.quickBlogSelectorCoordinator = quickBlogSelectorCoordinator
        self.tagCollection = tagCollection
        self.saveDirectory = saveDirectory
        cameraZoomHandler = CameraZoomHandler(analyticsProvider: analyticsProvider)
        feedbackGenerator = UINotificationFeedbackGenerator()
        super.init(nibName: .none, bundle: .none)
        cameraZoomHandler.delegate = self
    }

    @available(*, unavailable, message: "use init(settings:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(settings:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    /// Requests permissions for video
    ///
    /// - Parameter completion: boolean on whether access was granted
    public func requestAccess(_ completion: ((_ granted: Bool) -> ())?) {
        captureDeviceAuthorizer.requestAccess(for: AVMediaType.video) { videoGranted in
            performUIUpdate {
                completion?(videoGranted)
            }
        }
    }
    
    /// logs opening the camera
    public func logOpen() {
        analyticsProvider?.logCameraOpen(mode: currentMode)
    }
    
    /// logs closing the camera
    public func logDismiss() {
        analyticsProvider?.logDismiss()
    }

    // MARK: - View Lifecycle

    override public func loadView() {
        view = cameraView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if settings.features.cameraFilters {
            cameraView.addFiltersView(filterSettingsController.view)
        }
        cameraView.addModeView(modeAndShootController.view)
        
        if settings.features.multipleExports == false {
            cameraView.addClipsView(clipsController.view)
        }

        addChild(cameraInputController)
        cameraView.addCameraInputView(cameraInputController.view)
        cameraView.addOptionsView(topOptionsController.view)
        cameraView.addImagePreviewView(imagePreviewController.view)

        addChild(cameraPermissionsViewController)
        cameraView.addPermissionsView(cameraPermissionsViewController.view)

        bindMediaContentAvailable()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard cameraInputController.willCloseSoon == false else {
            return
        }
        if segments.isEmpty == false && showPreview {
            showPreviewWithSegments(segments, selected: segments.startIndex, edits: edits, animated: false)
            showPreview = false
        }
        if delegate?.cameraShouldShowWelcomeTooltip() == true && cameraPermissionsViewController.hasFullAccess() {
            showWelcomeTooltip()
        }
    }

    // MARK: - navigation

    private var segments: [CameraSegment] = []
    private var edits: [EditorViewController.Edit?]?
    private var showPreview: Bool = false
    
    private func showPreviewWithSegments(_ segments: [CameraSegment], selected: Array<CameraSegment>.Index, edits: [EditorViewController.Edit?]? = nil, animated: Bool = true) {
        guard view.superview != nil else {
            return
        }
        modeAndShootController.dismissTooltip()
        cameraInputController.stopSession()
        let controller = createNextStepViewController(segments, selected: selected, edits: edits)
        self.present(controller, animated: animated)
        mediaPlayerController = controller
        if controller is EditorViewController {
            analyticsProvider?.logEditorOpen()
        }
    }
    
    private func createNextStepViewController(_ segments: [CameraSegment], selected: Array<CameraSegment>.Index, edits: [EditorViewController.Edit?]?) -> MediaPlayerController {
        let controller: MediaPlayerController
        if settings.features.multipleExports && settings.features.editor {
            segments.forEach { segment in
                multiEditorViewController?.addSegment(segment)
            }
            controller = multiEditorViewController ?? createStoryViewController(segments, selected: selected, edits: edits)
            multiEditorViewController = controller as? MultiEditorViewController
        }
        else if settings.features.editor {
            let existing = existingEditor
            controller = existing ?? createEditorViewController(segments, selected: selected)
        }
        else {
            controller = createPreviewViewController(segments)
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
    
    private func createEditorViewController(_ segments: [CameraSegment], selected: Array<CameraSegment>.Index, edit: EditorViewController.Edit? = nil, drawing: IgnoreTouchesView? = nil) -> EditorViewController {
        let controller = EditorViewController(settings: settings,
                                              segments: segments,
                                              assetsHandler: segmentsHandler,
                                              exporterClass: MediaExporter.self,
                                              gifEncoderClass: GIFEncoderImageIO.self,
                                              cameraMode: currentMode,
                                              stickerProvider: stickerProvider,
                                              analyticsProvider: analyticsProvider,
                                              quickBlogSelectorCoordinator: quickBlogSelectorCoordinator,
                                              edit: edit,
                                              tagCollection: tagCollection)
        controller.delegate = self
        return controller
    }

    private func frames(segments: [CameraSegment], edits: [EditorViewController.Edit?]?) -> [MultiEditorViewController.Frame] {
        if let edits = edits {
            return zip(segments, edits).map { (segment, edit) in
                return MultiEditorViewController.Frame(segment: segment, edit: edit)
            }
        } else {
            return segments.map({ segment in
                return MultiEditorViewController.Frame(segment: segment, edit: nil)
            })
        }
    }

    private func createStoryViewController(_ segments: [CameraSegment], selected: Int, edits: [EditorViewController.Edit?]?) -> MultiEditorViewController {

        let controller = MultiEditorViewController(settings: settings,
                                                     frames: frames(segments: segments, edits: edits),
                                                     delegate: self,
                                                     selected: selected)
        return controller
    }

    private func createPreviewViewController(_ segments: [CameraSegment]) -> CameraPreviewViewController {
        let controller = CameraPreviewViewController(settings: settings, segments: segments, assetsHandler: segmentsHandler, cameraMode: currentMode)
        controller.delegate = self
        return controller
    }
    
    /// Shows the tooltip below the mode selector
    private func showWelcomeTooltip() {
        modeAndShootController.showTooltip()
    }

    /// Shows a generic alert
    private func showAlert(message: String, buttonMessage: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: buttonMessage, style: .default)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func showDismissTooltip() {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("Are you sure? If you close this, you'll lose everything you just created.", comment: "Popup message when user discards all their clips"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel alert controller"), style: .cancel)
        let discardAction = UIAlertAction(title: NSLocalizedString("I'm sure", comment: "Confirmation to discard all the clips"), style: .destructive) { [weak self] (UIAlertAction) in
            self?.handleCloseButtonPressed()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(discardAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Media Content Creation

    class func save(data: Data, to filename: String, ext fileExtension: String) throws -> URL {
        let fileURL = try URL(filename: filename, fileExtension: fileExtension, unique: false, removeExisting: true)
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    private func durationStringForAssetAtURL(_ url: URL?) -> String {
        var text = ""
        if let url = url {
            let asset = AVURLAsset(url: url)
            let seconds = CMTimeGetSeconds(asset.duration).rounded()
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.zeroFormattingBehavior = .pad
            if let time = formatter.string(from: seconds) {
                text = time
            }
        }
        return text
    }
    
    private func getLastFrameFrom(_ url: URL) -> UIImage {
        let asset = AVURLAsset(url: url, options: nil)
        let generate = AVAssetImageGenerator(asset: asset)
        generate.appliesPreferredTrackTransform = true
        let lastFrameTime = CMTimeGetSeconds(asset.duration) * 60.0
        let time = CMTimeMake(value: Int64(lastFrameTime), timescale: 2)
        do {
            let cgImage = try generate.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        }
        catch {
            return UIImage()
        }
    }

    private func takeGif(numberOfFrames: Int, framesPerSecond: Int) {
        guard !isRecording else { return }
        updatePhotoCaptureState(event: .started)
        AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
        cameraInputController.takeGif(numberOfFrames: numberOfFrames, framesPerSecond: framesPerSecond, completion: { [weak self] url in
            defer {
                self?.updatePhotoCaptureState(event: .ended)
            }
            guard let strongSelf = self else { return }
            strongSelf.analyticsProvider?.logCapturedMedia(type: strongSelf.currentMode,
                                                           cameraPosition: strongSelf.cameraInputController.currentCameraPosition,
                                                           length: 0,
                                                           ghostFrameEnabled: strongSelf.imagePreviewVisible(),
                                                           filterType: strongSelf.cameraInputController.currentFilterType ?? .off)
            performUIUpdate {
                if let url = url {
                    let segment = CameraSegment.video(url, MediaInfo(source: .kanvas_camera))
                    let segments = [segment]
                    strongSelf.showPreviewWithSegments(segments, selected: segments.startIndex)
                }
            }
        })
    }
    
    private func takePhoto() {
        guard !isRecording else { return }
        updatePhotoCaptureState(event: .started)
        cameraInputController.takePhoto(on: currentMode, completion: { [weak self] image in
            defer {
                self?.updatePhotoCaptureState(event: .ended)
            }
            guard let strongSelf = self else { return }
            strongSelf.analyticsProvider?.logCapturedMedia(type: strongSelf.currentMode,
                                                           cameraPosition: strongSelf.cameraInputController.currentCameraPosition,
                                                           length: 0,
                                                           ghostFrameEnabled: strongSelf.imagePreviewVisible(),
                                                           filterType: strongSelf.cameraInputController.currentFilterType ?? .off)
            performUIUpdate {
                let simulatorImage = Device.isRunningInSimulator ? UIImage() : nil
                if let image = image ?? simulatorImage {
                    let clip = MediaClip(representativeFrame: image, overlayText: nil, lastFrame: image)
                    if strongSelf.currentMode.quantity == .single {
                        let segments = [clip].map({ clip in
                            return CameraSegment.image(clip.representativeFrame, nil, nil, MediaInfo(source: .kanvas_camera))
                        })
                        if let lastIndex = segments.indices.last {
                            strongSelf.showPreviewWithSegments(segments, selected: lastIndex)
                        }
                    }
                    else {
                        if strongSelf.settings.features.multipleExports == false {
                            strongSelf.clipsController.addNewClip(MediaClip(representativeFrame: image,
                            overlayText: nil,
                            lastFrame: image))
                        }
                    }
                }
                else {
                    // TODO handle
                }
            }
        })
    }
    
    // MARK : - Mode handling
    private func updateMode(_ mode: CameraMode) {
        if mode != currentMode {
            currentMode = mode
            do {
                try cameraInputController.configureMode(mode)
            } catch {
                // we can ignore this error for now since configuring mode may not succeed for devices without all the modes available (flash, multiple cameras)
            }
        }
    }

    /// Is the image preview (ghost frame) visible?
    private func imagePreviewVisible() -> Bool {
        return accessUISync { [weak self] in
            return (self?.topOptionsController.imagePreviewOptionAvailable() ?? false) &&
                   (self?.imagePreviewController.imagePreviewVisible() ?? false)
        } ?? false
    }
    
    private enum RecordingEvent {
        case started
        case ended
    }
    
    /// This updates the camera view based on the current video recording state
    ///
    /// - Parameter event: The recording event (started or ended)
    private func updateRecordState(event: RecordingEvent) {
        isRecording = event == .started
        cameraView.updateUI(forRecording: isRecording)
        filterSettingsController.updateUI(forRecording: isRecording)
        toggleMediaPicker(visible: !isRecording)
        if isRecording {
            modeAndShootController.hideModeButton()
        }
        else if !isRecording && !clipsController.hasClips && settings.enabledModes.count > 1 {
            modeAndShootController.showModeButton()
        }
    }
    
    /// This enables the camera view user interaction based on the photo capture
    ///
    /// - Parameter event: The recording event state (started or ended)
    private func updatePhotoCaptureState(event: RecordingEvent) {
        isRecording = event == .started
        performUIUpdate {
            self.cameraView.isUserInteractionEnabled = !self.isRecording
        }
    }
    
    // MARK: - UI
    private func updateUI(forClipsPresent hasClips: Bool) {
        topOptionsController.configureOptions(areThereClips: hasClips)
        clipsController.showViews(hasClips)
        if hasClips || settings.enabledModes.count == 1 {
            modeAndShootController.hideModeButton()
        }
        else {
            modeAndShootController.showModeButton()
        }
    }
    
    /// Updates the fullscreen preview with the last image of the clip collection
    private func updateLastClipPreview() {
        imagePreviewController.setImagePreview(clipsController.getLastFrameFromLastClip())
    }
    
    // MARK: - Private utilities
    
    private func bindMediaContentAvailable() {
        disposables.append(clipsController.observe(\.hasClips) { [weak self] object, _ in
            performUIUpdate {
                self?.updateUI(forClipsPresent: object.hasClips)
            }
        })
        updateUI(forClipsPresent: clipsController.hasClips)
    }
    
    /// Prepares the device for giving haptic feedback
    private func prepareHapticFeedback() {
        feedbackGenerator.prepare()
    }
    
    /// Makes the device give haptic feedback
    private func generateHapticFeedback() {
        feedbackGenerator.notificationOccurred(.success)
    }
    
    // MARK: - CameraViewDelegate

    func closeButtonPressed() {
        modeAndShootController.dismissTooltip()
        // Let's prompt for losing clips if they have clips and it's the "x" button, rather than the ">" button.
        if clipsController.hasClips && !settings.topButtonsSwapped {
            showDismissTooltip()
        } else if multiEditorViewController != nil {
            showPreviewWithSegments([], selected: multiEditorViewController?.selected ?? 0)
        }
        else {
            handleCloseButtonPressed()
        }
    }

    func handleCloseButtonPressed() {
        performUIUpdate {
            self.delegate?.dismissButtonPressed(self)
        }
    }

    // MARK: - ModeSelectorAndShootControllerDelegate

    func didPanForZoom(_ mode: CameraMode, _ currentPoint: CGPoint, _ gesture: UILongPressGestureRecognizer) {
        if mode.group == .video {
            cameraZoomHandler.setZoom(point: currentPoint, gesture: gesture)
        }
    }

    func didOpenMode(_ mode: CameraMode, andClosed oldMode: CameraMode?) {
        updateMode(mode)
        toggleMediaPicker(visible: true)
    }

    func didTapForMode(_ mode: CameraMode) {
        switch mode.group {
        case .gif:
            takeGif(numberOfFrames: KanvasTimes.gifTapNumberOfFrames, framesPerSecond: KanvasTimes.gifPreferredFramesPerSecond)
        case .photo, .video:
            takePhoto()
        }
    }

    func didStartPressingForMode(_ mode: CameraMode) {
        switch mode.group {
        case .gif:
            takeGif(numberOfFrames: KanvasTimes.gifHoldNumberOfFrames, framesPerSecond: KanvasTimes.gifPreferredFramesPerSecond)
        case .video:
            prepareHapticFeedback()
            let _ = cameraInputController.startRecording(on: mode)
            performUIUpdate { [weak self] in
                self?.updateRecordState(event: .started)
            }
        case .photo:
            break
        }
    }

    func didEndPressingForMode(_ mode: CameraMode) {
        switch mode.group {
        case .video:
            cameraInputController.endRecording(completion: { [weak self] url in
                guard let strongSelf = self else { return }
                if let videoURL = url {
                    let asset = AVURLAsset(url: videoURL)
                    strongSelf.analyticsProvider?.logCapturedMedia(type: strongSelf.currentMode,
                                                                   cameraPosition: strongSelf.cameraInputController.currentCameraPosition,
                                                                   length: CMTimeGetSeconds(asset.duration),
                                                                   ghostFrameEnabled: strongSelf.imagePreviewVisible(),
                                                                   filterType: strongSelf.cameraInputController.currentFilterType ?? .off)
                }
                performUIUpdate {
                    if let url = url {
                        if mode.quantity == .single {
                            let segments = [CameraSegment.video(url, MediaInfo(source: .kanvas_camera))]
                            strongSelf.showPreviewWithSegments(segments, selected: segments.startIndex)
                        }
                        else if let image = AVURLAsset(url: url).thumbnail() {
                            strongSelf.clipsController.addNewClip(MediaClip(representativeFrame: image,
                                                                            overlayText: strongSelf.durationStringForAssetAtURL(url),
                                                                            lastFrame: strongSelf.getLastFrameFrom(url)))
                            
                        }
                    }
                    
                    strongSelf.updateRecordState(event: .ended)
                    strongSelf.generateHapticFeedback()
                }
            })
        default: break
        }
    }
    
    func didDropToDelete(_ mode: CameraMode) {
        switch mode.quantity {
        case .multiple:
            clipsController.removeDraggingClip()
        case .single:
            break
        }
    }
    
    func didDismissWelcomeTooltip() {
        delegate?.didDismissWelcomeTooltip()
    }

    func didTapMediaPickerButton(completion: (() -> ())? = nil) {
        presentPicker(completion: completion)
        analyticsProvider?.logMediaPickerOpen()
    }

    open func presentPicker(completion: (() -> ())? = nil) -> Void {
        mediaPicker.present(on: self, with: settings, delegate: self, completion: {
            self.modeAndShootController.resetMediaPickerButton()
            completion?()
        })
    }

    func updateMediaPickerThumbnail(targetSize: CGSize) {
        mediaPickerThumbnailFetcher.thumbnailTargetSize = targetSize
        mediaPickerThumbnailFetcher.updateThumbnail()
    }

    // MARK: - OptionsCollectionControllerDelegate (Top Options)

    func optionSelected(_ item: CameraOption) {
        switch item {
        case .flashOn:
            cameraInputController.setFlashMode(on: true)
            analyticsProvider?.logFlashToggled()
        case .flashOff:
            cameraInputController.setFlashMode(on: false)
            analyticsProvider?.logFlashToggled()
        case .backCamera, .frontCamera:
            cameraInputController.switchCameras()
            analyticsProvider?.logFlipCamera()
            cameraZoomHandler.resetZoom()
        case .imagePreviewOn:
            imagePreviewController.showImagePreview(true)
            analyticsProvider?.logImagePreviewToggled(enabled: true)
        case .imagePreviewOff:
            imagePreviewController.showImagePreview(false)
            analyticsProvider?.logImagePreviewToggled(enabled: false)
        }
    }

    // MARK: - MediaClipsEditorDelegate
    
    func mediaClipWasSelected(at: Int) {
        // No-op, don't need to do anything
    }

    func mediaClipStartedMoving() {
        delegate?.didBeginDragInteraction()
        modeAndShootController.enableShootButtonUserInteraction(true)
        modeAndShootController.enableShootButtonGestureRecognizers(false)
        performUIUpdate { [weak self] in
            self?.cameraView.updateUI(forDraggingClip: true)
            self?.modeAndShootController.closeTrash()
            self?.toggleMediaPicker(visible: false)
            self?.clipsController.hidePreviewButton()
        }
    }

    func mediaClipFinishedMoving() {
        analyticsProvider?.logMovedClip()
        delegate?.didEndDragInteraction()
        let filterSelectorVisible = filterSettingsController.isFilterSelectorVisible()
        modeAndShootController.enableShootButtonUserInteraction(!filterSelectorVisible)
        modeAndShootController.enableShootButtonGestureRecognizers(true)
        performUIUpdate { [weak self] in
            self?.cameraView.updateUI(forDraggingClip: false)
            self?.modeAndShootController.hideTrash()
            self?.toggleMediaPicker(visible: true)
            self?.clipsController.showPreviewButton()
        }
    }

    func mediaClipWasDeleted(at index: Int) {
        cameraInputController.deleteSegment(at: index)
        delegate?.didEndDragInteraction()
        let filterSelectorVisible = filterSettingsController.isFilterSelectorVisible()
        modeAndShootController.enableShootButtonUserInteraction(!filterSelectorVisible)
        modeAndShootController.enableShootButtonGestureRecognizers(true)
        performUIUpdate { [weak self] in
            self?.cameraView.updateUI(forDraggingClip: false)
            self?.modeAndShootController.hideTrash()
            self?.toggleMediaPicker(visible: true)
            self?.clipsController.showPreviewButton()
            self?.updateLastClipPreview()
        }
        analyticsProvider?.logDeleteSegment()
    }

    func mediaClipWasAdded(at index: Int) {
        updateLastClipPreview()
    }

    func mediaClipWasMoved(from originIndex: Int, to destinationIndex: Int) {
        cameraInputController.moveSegment(from: originIndex, to: destinationIndex)
        updateLastClipPreview()
    }
    
    func nextButtonWasPressed() {
        if let lastSegment = cameraInputController.segments().last {
            let segments = [lastSegment]
            showPreviewWithSegments(segments, selected: segments.startIndex)
        }
        analyticsProvider?.logNextTapped()
    }
    
    private var existingEditor: EditorViewController?
    private var multiEditorViewController: MultiEditorViewController?

    func addButtonWasPressed() {
        existingEditor = presentedViewController as? EditorViewController
        dismiss(animated: false, completion: nil)
    }

    func editor(segment: CameraSegment, edit: EditorViewController.Edit?) -> EditorViewController {
        let segments = [segment]

        return createEditorViewController(segments, selected: segments.startIndex, edit: edit)
    }
    
    // MARK: - CameraPreviewControllerDelegate & EditorControllerDelegate & StoryComposerDelegate

    func didFinishExportingVideo(url: URL?) {
        didFinishExportingVideo(url: url, info: MediaInfo(source: .kanvas_camera), archive: nil, action: .previewConfirm, mediaChanged: true)
    }

    func didFinishExportingImage(image: UIImage?) {
        didFinishExportingImage(image: image, info: MediaInfo(source: .kanvas_camera), archive: nil, action: .previewConfirm, mediaChanged: true)
    }

    func didFinishExportingFrames(url: URL?) {
        var size: CGSize? = nil
        if let url = url {
            size = GIFDecoderFactory.main().size(of: url)
        }
        didFinishExportingFrames(url: url, size: size, info: MediaInfo(source: .kanvas_camera), archive: nil, action: .previewConfirm, mediaChanged: true)
    }

    public func didFinishExportingVideo(url: URL?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {
        guard settings.features.multipleExports == false else { return }
        let asset: AVURLAsset?
        if let url = url {
            asset = AVURLAsset(url: url)
        }
        else {
            asset = nil
        }

        if let asset = asset, let info = info {
            let media = KanvasMedia(asset: asset, original: nil, info: info, archive: nil)
            logMediaCreation(action: action, clipsCount: cameraInputController.segments().count, length: CMTimeGetSeconds(asset.duration))
            performUIUpdate { [weak self] in
                if let self = self {
                    self.existingEditor?.hideLoading()
                    self.handleCloseSoon(action: action)
                    self.delegate?.didCreateMedia(self, media: [.success(media)], exportAction: action)
                }
            }
        } else {
            performUIUpdate { [weak self] in
                if let self = self {
                    self.existingEditor?.hideLoading()
                    self.handleCloseSoon(action: action)
                    self.delegate?.didCreateMedia(self, media: [.failure(CameraControllerError.exportFailure)], exportAction: action)
                }
            }
        }
    }

    public func didFinishExportingImage(image: UIImage?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {
        guard settings.features.multipleExports == false else { return }
        if let image = image, let info = info, let url = image.save(info: info) {
            let media = KanvasMedia(image: image, url: url, original: nil, info: info, archive: nil)
            logMediaCreation(action: action, clipsCount: 1, length: 0)
            performUIUpdate { [weak self] in
                if let self = self {
                    self.existingEditor?.hideLoading()
                    self.handleCloseSoon(action: action)
                    self.delegate?.didCreateMedia(self, media: [.success(media)], exportAction: action)
                }
            }
        }
        else {
            performUIUpdate { [weak self] in
                if let self = self {
                    self.existingEditor?.hideLoading()
                    self.handleCloseSoon(action: action)
                    self.delegate?.didCreateMedia(self, media: [.failure(CameraControllerError.exportFailure)], exportAction: action)
                }
            }
        }
    }

    public func didFinishExportingFrames(url: URL?, size: CGSize?, info: MediaInfo?, archive: Data?, action: KanvasExportAction, mediaChanged: Bool) {
        guard settings.features.multipleExports == false else { return }
        guard let url = url, let info = info, let size = size, size != .zero else {
            performUIUpdate {
                self.existingEditor?.hideLoading()
                self.handleCloseSoon(action: action)
                self.delegate?.didCreateMedia(self, media: [.failure(CameraControllerError.exportFailure)], exportAction: action)
            }
            return
        }
        performUIUpdate {
            self.existingEditor?.hideLoading()
            self.handleCloseSoon(action: action)
            let media = KanvasMedia(unmodified: nil, output: url, info: info, size: size, archive: nil, type: .frames)
            self.delegate?.didCreateMedia(self, media: [.success(media)], exportAction: action)
        }
    }

    public func didFailExporting() {
        performUIUpdate {
            self.existingEditor?.hideLoading()
        }
    }

    lazy var queue = DispatchQueue.global(qos: .background)

    var exportCancellable: Any?

    func didFinishExporting(media result: [Result<EditorViewController.ExportResult, Error>]) {

        let archiver = MediaArchiver(saveDirectory: saveDirectory)

        queue.async { [weak self] in
            guard let self = self else { return }
            let exports: [EditorViewController.ExportResult?] = result.map { result in
                switch result {
                case .success(let export):
                    return export
                case .failure(_):
                    return nil
                }
            }

            let publishers = archiver.handle(exports: exports)
            self.exportCancellable = publishers.receive(on: DispatchQueue.main).sink { completion in
                self.multiEditorViewController?.hideLoading()
            } receiveValue: { items in
                self.handleCloseSoon(action: .previewConfirm)
                self.delegate?.didCreateMedia(self, media: items, exportAction: .post)
            }
        }
    }

    func handleCloseSoon(action: KanvasExportAction) {
        cameraInputController.willCloseSoon = action == .previewConfirm
    }

    func logMediaCreation(action: KanvasExportAction, clipsCount: Int, length: TimeInterval) {
        switch action {
        case .previewConfirm:
            analyticsProvider?.logConfirmedMedia(mode: currentMode, clipsCount: clipsCount, length: length)
        case .confirm, .post, .save, .postOptions, .confirmPostOptions:
            analyticsProvider?.logEditorCreatedMedia(clipsCount: clipsCount, length: length)
        }
    }

    public func dismissButtonPressed() {
        if settings.features.editor {
            analyticsProvider?.logEditorBack()
        }
        else {
            analyticsProvider?.logPreviewDismissed()
        }
        if settings.features.multipleExports {
            delegate?.editorDismissed(self)
            showPreviewWithSegments([], selected: multiEditorViewController?.selected ?? 0)
        } else {
            performUIUpdate { [weak self] in
                self?.dismiss(animated: true)
            }
            delegate?.editorDismissed(self)
        }
    }

    public func tagButtonPressed() {
        delegate?.tagButtonPressed()
    }
    
    public func editorShouldShowColorSelectorTooltip() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowColorSelectorTooltip()
    }
    
    public func didDismissColorSelectorTooltip() {
        delegate?.didDismissColorSelectorTooltip()
    }
    
    public func editorShouldShowStrokeSelectorAnimation() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowStrokeSelectorAnimation()
    }
    
    public func didEndStrokeSelectorAnimation() {
        delegate?.didEndStrokeSelectorAnimation()
    }
    
    public func getQuickPostButton() -> UIView {
        guard let delegate = delegate else { return UIView() }
        return delegate.getQuickPostButton()
    }
    
    public func getBlogSwitcher() -> UIView {
        guard let delegate = delegate else { return UIView() }
        return delegate.getBlogSwitcher()
    }
    
    // MARK: CameraZoomHandlerDelegate
    var currentDeviceForZooming: AVCaptureDevice? {
        return cameraInputController.currentDevice
    }
    
    // MARK: CameraInputControllerDelegate
    func cameraInputControllerShouldResetZoom() {
        cameraZoomHandler.resetZoom()
    }
    
    func cameraInputControllerPinched(gesture: UIPinchGestureRecognizer) {
        cameraZoomHandler.setZoom(gesture: gesture)
    }

    func cameraInputControllerHasFullAccess() -> Bool {
        return cameraPermissionsViewController.hasFullAccess()
    }
    
    // MARK: - FilterSettingsControllerDelegate
    
    func didSelectFilter(_ filterItem: FilterItem, animated: Bool) {
        cameraInputController.applyFilter(filterType: filterItem.type)
        if animated {
            analyticsProvider?.logFilterSelected(filterType: filterItem.type)
        }
    }
    
    func didTapSelectedFilter(recognizer: UITapGestureRecognizer) {
        modeAndShootController.tapShootButton(recognizer: recognizer)
    }
    
    func didLongPressSelectedFilter(recognizer: UILongPressGestureRecognizer) {
        modeAndShootController.longPressShootButton(recognizer: recognizer)
    }
    
    func didTapVisibilityButton(visible: Bool) {
        if visible {
            analyticsProvider?.logOpenFiltersSelector()
        }
        modeAndShootController.enableShootButtonUserInteraction(!visible)
        toggleMediaPicker(visible: !visible)
        modeAndShootController.dismissTooltip()
    }

    // MARK: - CameraPermissionsViewControllerDelegate

    func cameraPermissionsChanged(hasFullAccess: Bool) {
        if hasFullAccess {
            cameraInputController.setupCaptureSession()
            toggleMediaPicker(visible: true, animated: false)
        }
    }

    func openAppSettings(completion: ((Bool) -> ())?) {
        delegate?.openAppSettings(completion: completion)
    }

    /// Toggles the media picker
    /// This takes the current camera mode and filter selector visibility into account, as the media picker should
    /// only be shown in Normal mode when the filter selector is hidden.
    ///
    /// - Parameters
    ///   - visible: Whether to make the button visible or not.
    ///   - animated: Whether to animate the transition.
    private func toggleMediaPicker(visible: Bool, animated: Bool = true) {
        if visible {
            if !filterSettingsController.isFilterSelectorVisible() && cameraPermissionsViewController.hasFullAccess() {
                modeAndShootController.showMediaPickerButton(basedOn: currentMode, animated: animated)
            }
            else {
                modeAndShootController.toggleMediaPickerButton(settings.features.cameraFilters == false, animated: animated)
            }
        }
        else {
            modeAndShootController.toggleMediaPickerButton(false, animated: animated)
        }
    }

    // MARK: - KanvasMediaPickerViewControllerDelegate

    private func segment(image: UIImage, imageURL: URL?) -> CameraSegment {
        let mediaInfo: MediaInfo = {
            guard let imageURL = imageURL else { return MediaInfo(source: .media_library) }
            return MediaInfo(fromImage: imageURL) ?? MediaInfo(source: .media_library)
        }()

        return CameraSegment.image(image, nil, nil, mediaInfo)
    }

    private func segment(video url: URL) -> CameraSegment {
        let mediaInfo = MediaInfo(fromVideoURL: url) ?? MediaInfo(source: .media_library)
        return CameraSegment.video(url, mediaInfo)

    }

    public func didPick(media: [PickedMedia]) {

        let mediaTypes = media.map { media -> KanvasMediaType in
            switch media {
            case .image:
                return .image
            case .video:
                return .video
            case .gif:
                return .frames
            case .livePhoto:
                return .livePhoto
            }
        }

        defer {
            analyticsProvider?.logMediaPickerPickedMedia(ofTypes: mediaTypes)
        }

        // Handle gifs and live photos separately, as they should not be chosen when multiple selection is enabled.
        switch media.first {
        case .gif(let url):
            let mediaInfo: MediaInfo = {
                return MediaInfo(fromImage: url) ?? MediaInfo(source: .media_library)
            }()
            GIFDecoderFactory.main().decode(image: url) { frames in
                let segments = frames.map { CameraSegment.image(UIImage(cgImage: $0.image), nil, $0.interval, mediaInfo) }
                self.showPreviewWithSegments(segments, selected: segments.endIndex)
            }
            return
        case .livePhoto(let livePhotoStill, let pairedVideo):
            let mediaInfo = MediaInfo(source: .media_library)
            if currentMode.quantity == .single {
                let segments = [CameraSegment.image(livePhotoStill, pairedVideo, nil, mediaInfo)]
                self.showPreviewWithSegments(segments, selected: segments.startIndex)
            }
            else {
                assertionFailure("No media picking from stitch yet")
            }
            return
        default:
            break
        }

        let segments = media.compactMap { media -> CameraSegment? in
            switch media {
            case .image(let image, let imageURL):
                return segment(image: image, imageURL: imageURL)
            case .video(let url):
                return segment(video: url)
            case .gif, .livePhoto:
                // Should not get here from code above
                return nil
            }
        }

        performUIUpdate {
            self.showPreviewWithSegments(segments, selected: segments.startIndex)
        }
    }

    public func didCancel() {
        analyticsProvider?.logMediaPickerDismiss()
    }

    public func pickingMediaNotAllowed(reason: String) {
        let buttonMessage = NSLocalizedString("Got it", comment: "Got it")
        showAlert(message: reason, buttonMessage: buttonMessage)
    }

    // MARK: - MediaPickerThumbnailFetcherDelegate

    func didUpdateThumbnail(image: UIImage) {
        self.modeAndShootController.setMediaPickerButtonThumbnail(image)
    }

    // MARK: - breakdown
    
    /// This function should be called to stop the camera session and properly breakdown the inputs
    public func cleanup() {
        resetState()
        cameraInputController.cleanup()
        mediaPickerThumbnailFetcher.cleanup()
    }

    public func resetState() {
        mediaPlayerController?.dismiss(animated: true, completion: nil)
        clipsController.removeAllClips()
        cameraInputController.deleteAllSegments()
        multiEditorViewController = nil
        imagePreviewController.setImagePreview(nil)
    }

    // MARK: - Post Options Interaction

    public func onPostOptionsDismissed() {
        mediaPlayerController?.onPostingOptionsDismissed()
    }
    
    public func onQuickPostButtonSubmitted() {
        mediaPlayerController?.onQuickPostButtonSubmitted()
    }
    
    public func onQuickPostOptionsShown(visible: Bool, hintText: String?, view: UIView) {
        mediaPlayerController?.onQuickPostOptionsShown(visible: visible, hintText: hintText, view: view)
    }
    
    public func onQuickPostOptionsSelected(selected: Bool, hintText: String?, view: UIView) {
        mediaPlayerController?.onQuickPostOptionsSelected(selected: selected, hintText: hintText, view: view)
    }
}

//MARK: Archival

extension CameraController {
    public static func unarchive(_ url: URL) throws -> (CameraSegment, Data?) {
        let data = try Data(contentsOf: url)
        let archive = try NSKeyedUnarchiver.unarchivedObject(ofClass: Archive.self, from: data)
        let segment: CameraSegment
        if let image = archive?.image {
            let info: MediaInfo
            if let imageData = image.jpegData(compressionQuality: 1.0), let mInfo = MediaInfo(fromImageData: imageData) {
                info = mInfo
            } else {
                info = MediaInfo(source: .kanvas_camera)
            }
            segment = CameraSegment.image(image, nil, nil, info)
        } else if let video = archive?.video {
            segment = CameraSegment.video(video, MediaInfo(fromVideoURL: video))
        } else {
            throw ArchiveErrors.unknownMedia
        }
        return (segment, archive?.data)
    }

    public func show(media: [(CameraSegment, Data?)]) {
        showPreview = true
        self.segments = media.map({ return $0.0 })
        self.edits = media.map { (_, data) in
            if let data = data {
                do {
                    return try NSKeyedUnarchiver.unarchivedObject(ofClass: EditorViewController.Edit.self, from: data)
                } catch let error {
                    assertionFailure("Failed to unarchive frame edit: \(error)")
                    return nil
                }
            } else {
                return nil
            }
        }

        if view.superview != nil {
            showPreviewWithSegments(segments, selected: segments.startIndex, edits: nil, animated: false)
        }
    }
}
