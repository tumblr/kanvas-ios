//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit
import MobileCoreServices
import Photos
import Utils

// Media wrapper for media generated from the CameraController
public enum KanvasCameraMedia {
    case image(URL, TumblrMediaInfo)
    case video(URL, TumblrMediaInfo)

    public var info: TumblrMediaInfo {
        switch self {
        case .image(_, let info): return info
        case .video(_, let info): return info
        }
    }
}

public enum KanvasExportAction {
    case previewConfirm
    case confirm
    case post
    case save
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
     - parameter media: KanvasCameraMedia - this is the media created in the controller (can be image, video, etc)
     - seealso: enum KanvasCameraMedia
     */
    func didCreateMedia(media: KanvasCameraMedia?, exportAction: KanvasExportAction, error: Error?)

    /**
     A function that is called when the main camera dismiss button is pressed
     */
    func dismissButtonPressed()

    /// Called when the tag button is pressed in the editor
    func tagButtonPressed()

    /// Called when the editor is dismissed
    func editorDismissed()
    
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
    
    func provideMediaPickerThumbnail(targetSize: CGSize, completion: @escaping (UIImage?) -> Void)
    
    /// Called when a drag interaction starts
    func didBeginDragInteraction()
    
    /// Called when a drag interaction ends
    func didEndDragInteraction()
}

// A controller that contains and layouts all camera handling views and controllers (mode selector, input, etc).
public class CameraController: UIViewController, MediaClipsEditorDelegate, CameraPreviewControllerDelegate, EditorControllerDelegate, CameraZoomHandlerDelegate, OptionsControllerDelegate, ModeSelectorAndShootControllerDelegate, CameraViewDelegate, CameraInputControllerDelegate, FilterSettingsControllerDelegate, CameraPermissionsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        let controller = MediaClipsEditorViewController()
        controller.delegate = self
        return controller
    }()

    private lazy var cameraInputController: CameraInputController = {
        let controller = CameraInputController(settings: self.settings, recorderClass: self.recorderClass, segmentsHandler: self.segmentsHandler, delegate: self)
        addChild(controller)
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
        let controller = CameraPermissionsViewController()
        controller.delegate = self
        return controller
    }()

    private lazy var segmentsHandler: SegmentsHandlerType = {
        return segmentsHandlerClass.init()
    }()
    
    private let settings: CameraSettings
    private let analyticsProvider: KanvasCameraAnalyticsProvider?
    private var currentMode: CameraMode
    private var isRecording: Bool
    private var disposables: [NSKeyValueObservation] = []
    private var recorderClass: CameraRecordingProtocol.Type
    private var segmentsHandlerClass: SegmentsHandlerType.Type
    private let stickerProviderClass: StickerProvider.Type
    private let cameraZoomHandler: CameraZoomHandler
    private let feedbackGenerator: UINotificationFeedbackGenerator
    private var mediaPickerThumbnailTargetSize: CGSize = CGSize(width: 0, height: 0)
    private var lastMediaPickerFetchResult: PHFetchResult<PHAsset>?
    private var mediaPickerThumbnailQueue = DispatchQueue(label: "kanvas.mediaPickerThumbnailQueue")

    private weak var overlayViewController: UIViewController?

    private var didRegisterForPhotoLibraryChanges: Bool = false

    /// Constructs a CameraController that will record from the device camera
    /// and export the result to the device, saving to the phone all in between information
    /// needed to attain the final output.
    ///
    /// - Parameter settings: Settings to configure in which ways should the controller
    /// interact with the user, which options should the controller give the user
    /// and which should be the result of the interaction.
    ///   - analyticsProvider: An class conforming to KanvasCameraAnalyticsProvider
    ///   - stickerProvider: An class conforming to StickerProvider
    convenience public init(settings: CameraSettings, stickerProviderClass: StickerProvider.Type, analyticsProvider: KanvasCameraAnalyticsProvider?) {
        self.init(settings: settings, recorderClass: CameraRecorder.self, segmentsHandlerClass: CameraSegmentHandler.self, stickerProviderClass: stickerProviderClass, analyticsProvider: analyticsProvider)
    }

    /// Constructs a CameraController that will take care of creating media
    /// as the result of user interaction.
    ///
    /// - Parameters:
    ///   - settings: Settings to configure in which ways should the controller
    /// interact with the user, which options should the controller give the user
    /// and which should be the result of the interaction.
    ///   - recorderClass: Class that will provide a recorder that defines how to record media.
    ///   - segmentsHandlerClass: Class that will provide a segments handler for storing stop
    /// motion segments and constructing final input.
    init(settings: CameraSettings,
         recorderClass: CameraRecordingProtocol.Type,
         segmentsHandlerClass: SegmentsHandlerType.Type,
         stickerProviderClass: StickerProvider.Type,
         analyticsProvider: KanvasCameraAnalyticsProvider?) {
        self.settings = settings
        currentMode = settings.initialMode
        isRecording = false
        self.recorderClass = recorderClass
        self.segmentsHandlerClass = segmentsHandlerClass
        self.stickerProviderClass = stickerProviderClass
        self.analyticsProvider = analyticsProvider
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
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { videoGranted in
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
        cameraView.addClipsView(clipsController.view)
        cameraView.addCameraInputView(cameraInputController.view)
        cameraView.addOptionsView(topOptionsController.view)
        cameraView.addImagePreviewView(imagePreviewController.view)

        addChild(cameraPermissionsViewController)
        cameraView.addPermissionsView(cameraPermissionsViewController.view)

        bindMediaContentAvailable()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if delegate?.cameraShouldShowWelcomeTooltip() == true && cameraPermissionsViewController.hasFullAccess() {
            showWelcomeTooltip()
        }
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    // MARK: - navigation
    
    private func showPreviewWithSegments(_ segments: [CameraSegment]) {
        cameraInputController.stopSession()
        let controller = createNextStepViewController(segments)
        self.present(controller, animated: true)
        overlayViewController = controller
        if controller is EditorViewController {
            analyticsProvider?.logEditorOpen()
        }
    }
    
    private func createNextStepViewController(_ segments: [CameraSegment]) -> UIViewController {
        let controller: UIViewController
        if settings.features.editor {
            controller = createEditorViewController(segments)
        }
        else {
            controller = createPreviewViewController(segments)
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
    
    private func createEditorViewController(_ segments: [CameraSegment]) -> EditorViewController {
        let controller = EditorViewController(settings: settings, segments: segments, assetsHandler: segmentsHandler, exporterClass: MediaExporter.self, stickerProviderClass: stickerProviderClass, cameraMode: currentMode, analyticsProvider: analyticsProvider)
        controller.delegate = self
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
    class func saveImageToFile(_ image: UIImage?, info: TumblrMediaInfo) -> URL? {
        // TODO: Use NSURL.createNewImageURL rather than duplicate logic here
        // https://jira.tumblr.net/browse/KANVAS-575
        do {
            guard let image = image, let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
            }
            if !FileManager.default.fileExists(atPath: documentsURL.path, isDirectory: nil) {
                try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
            }
            let fileURL = documentsURL.appendingPathComponent("kanvas-camera-image.jpg", isDirectory: false)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            if let jpgImageData = image.jpegData(compressionQuality: 1.0) {
                try jpgImageData.write(to: fileURL, options: .atomic)
                info.write(toImage: fileURL)
            }
            return fileURL
        } catch {
            NSLog("failed to save to file. Maybe parent directories couldn't be created.")
            return nil
        }
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
                    let segment = CameraSegment.video(url, TumblrMediaInfo(source: .kanvas_camera))
                    strongSelf.showPreviewWithSegments([segment])
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
                if let image = image {
                    if strongSelf.currentMode.quantity == .single {
                        strongSelf.showPreviewWithSegments([CameraSegment.image(image, nil, TumblrMediaInfo(source: .kanvas_camera))])
                    }
                    else {
                        strongSelf.clipsController.addNewClip(MediaClip(representativeFrame: image,
                                                                        overlayText: nil,
                                                                        lastFrame: image))
                    }
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
        if isRecording {
            modeAndShootController.hideModeButton()
            toggleMediaPicker(visible: false)
        }
        else {
            toggleMediaPicker(visible: true)
            // If it finished recording, then there is at least one clip and button shouldn't be shown.
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
    
    // MARK : - Private utilities
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
        }
        else {
            handleCloseButtonPressed()
        }
    }

    func handleCloseButtonPressed() {
        performUIUpdate {
            self.delegate?.dismissButtonPressed()
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
            takeGif(numberOfFrames: KanvasCameraTimes.gifTapNumberOfFrames, framesPerSecond: KanvasCameraTimes.gifPreferredFramesPerSecond)
        case .photo, .video:
            takePhoto()
        }
    }

    func didStartPressingForMode(_ mode: CameraMode) {
        switch mode.group {
        case .gif:
            takeGif(numberOfFrames: KanvasCameraTimes.gifHoldNumberOfFrames, framesPerSecond: KanvasCameraTimes.gifPreferredFramesPerSecond)
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
                            strongSelf.showPreviewWithSegments([CameraSegment.video(url, TumblrMediaInfo(source: .kanvas_camera))])
                            strongSelf.updateRecordState(event: .ended)
                            strongSelf.updateUI(forClipsPresent: false)
                        }
                        else if let image = AVURLAsset(url: url).thumbnail() {
                            strongSelf.clipsController.addNewClip(MediaClip(representativeFrame: image,
                                                                            overlayText: strongSelf.durationStringForAssetAtURL(url),
                                                                            lastFrame: strongSelf.getLastFrameFrom(url)))
                            strongSelf.updateRecordState(event: .ended)
                        }
                    }
                    
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
        let imagePickerController = KanvasUIImagePickerViewController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = false
        imagePickerController.mediaTypes = ["\(kUTTypeMovie)", "\(kUTTypeImage)"]
        present(imagePickerController, animated: true) {
            self.modeAndShootController.resetMediaPickerButton()
            completion?()
        }
        analyticsProvider?.logMediaPickerOpen()
    }

    func provideMediaPickerThumbnail(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        mediaPickerThumbnailTargetSize = targetSize
        self.delegate?.provideMediaPickerThumbnail(targetSize: targetSize) { [weak self] image in
            if let image = image {
                completion(image)
                return
            }
            else {
                self?.fetchMostRecentPhotoLibraryImage(targetSize: targetSize, completion: completion)
            }
        }
    }

    private func fetchMostRecentPhotoLibraryImage(targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {

        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            performUIUpdate {
                completion(nil)
            }
            return
        }

        // PHPhotoLibrary.register prompts for Photo Pibrary access, so ensure this line always happens after the PHPhotoLibrary.authorizationStatus check.
        if !didRegisterForPhotoLibraryChanges {
            PHPhotoLibrary.shared().register(self)
            didRegisterForPhotoLibraryChanges = true
        }

        mediaPickerThumbnailQueue.async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 1
            // PHAsset.fetchAssets prompts for photo library access, so ensure this line always happens after the PHPhotoLibrary.authorizationStatus check.
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
            self.lastMediaPickerFetchResult = fetchResult
            if fetchResult.count > 0 {
                let requestOptions = PHImageRequestOptions()
                requestOptions.deliveryMode = .opportunistic
                requestOptions.resizeMode = .fast
                let lastMediaPickerAsset = fetchResult.object(at: 0) as PHAsset
                PHImageManager.default().requestImage(for: lastMediaPickerAsset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                    performUIUpdate {
                        completion(image)
                    }
                })
            }
            else {
                performUIUpdate {
                    completion(nil)
                }
            }
        }
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
        showPreviewWithSegments(cameraInputController.segments())
        analyticsProvider?.logNextTapped()
    }

    // MARK: - CameraPreviewControllerDelegate & EditorControllerDelegate

    func didFinishExportingVideo(url: URL?) {
        didFinishExportingVideo(url: url, info: TumblrMediaInfo(source: .kanvas_camera), action: .previewConfirm)
    }

    func didFinishExportingImage(image: UIImage?) {
        didFinishExportingImage(image: image, info: TumblrMediaInfo(source: .kanvas_camera), action: .previewConfirm)
    }

    func didFinishExportingVideo(url: URL?, info: TumblrMediaInfo?, action: KanvasExportAction) {
        if let url = url, let info = info {
            let asset = AVURLAsset(url: url)
            logMediaCreation(action: action, clipsCount: cameraInputController.segments().count, length: CMTimeGetSeconds(asset.duration))
            performUIUpdate { [weak self] in
                self?.handleCloseSoon(action: action)
                self?.delegate?.didCreateMedia(media: .video(url, info), exportAction: action, error: nil)
            }
        }
        else {
            performUIUpdate { [weak self] in
                self?.handleCloseSoon(action: action)
                self?.delegate?.didCreateMedia(media: nil, exportAction: action, error: CameraControllerError.exportFailure)
            }
        }
    }

    func didFinishExportingImage(image: UIImage?, info: TumblrMediaInfo?, action: KanvasExportAction) {
        if let info = info, let url = CameraController.saveImageToFile(image, info: info) {
            logMediaCreation(action: action, clipsCount: 1, length: 0)
            performUIUpdate { [weak self] in
                self?.handleCloseSoon(action: action)
                self?.delegate?.didCreateMedia(media: .image(url, info), exportAction: action, error: nil)
            }
        }
        else {
            performUIUpdate { [weak self] in
                self?.handleCloseSoon(action: action)
                self?.delegate?.didCreateMedia(media: nil, exportAction: action, error: CameraControllerError.exportFailure)
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
        case .confirm, .post, .save:
            analyticsProvider?.logEditorCreatedMedia(clipsCount: clipsCount, length: length)
        }
    }

    func dismissButtonPressed() {
        if settings.features.editor {
            analyticsProvider?.logEditorBack()
        }
        else {
            analyticsProvider?.logPreviewDismissed()
        }
        performUIUpdate { [weak self] in
            self?.dismiss(animated: true)
        }
        delegate?.editorDismissed()
    }

    func tagButtonPressed() {
        delegate?.tagButtonPressed()
    }
    
    func editorShouldShowColorSelectorTooltip() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowColorSelectorTooltip()
    }
    
    func didDismissColorSelectorTooltip() {
        delegate?.didDismissColorSelectorTooltip()
    }
    
    func editorShouldShowStrokeSelectorAnimation() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.editorShouldShowStrokeSelectorAnimation()
    }
    
    func didEndStrokeSelectorAnimation() {
        delegate?.didEndStrokeSelectorAnimation()
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
        }
    }

    /// Toggles the media picker
    /// This takes the current camera mode and filter selector visibility into account, as the media picker should
    /// only be shown in Normal mode when the filter selector is hidden.
    private func toggleMediaPicker(visible: Bool) {
        if visible {
            if !filterSettingsController.isFilterSelectorVisible() {
                modeAndShootController.showMediaPickerButton(basedOn: currentMode)
            }
            else {
                modeAndShootController.toggleMediaPickerButton(false)
            }
        }
        else {
            modeAndShootController.toggleMediaPickerButton(false)
        }
    }

    // MARK: - UIImagePickerControllerDelegate

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        let imageMaybe = info[.originalImage] as? UIImage
        let mediaURLMaybe = info[.mediaURL] as? URL

        if let image = imageMaybe {
            pick(image: image, url: mediaURLMaybe)
            analyticsProvider?.logMediaPickerPickedMedia(ofType: .image)
        }
        else if let mediaURL = mediaURLMaybe {
            pick(video: mediaURL)
            analyticsProvider?.logMediaPickerPickedMedia(ofType: .video)
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        analyticsProvider?.logMediaPickerDismiss()
    }

    private func pick(image: UIImage, url: URL?) {
        let mediaInfo: TumblrMediaInfo = {
            guard let url = url else { return TumblrMediaInfo(source: .media_library) }
            return TumblrMediaInfo(fromImage: url) ?? TumblrMediaInfo(source: .media_library)
        }()
        if currentMode.quantity == .single {
            performUIUpdate {
                self.showPreviewWithSegments([CameraSegment.image(image, nil, mediaInfo)])
            }
        }
        else {
            segmentsHandler.addNewImageSegment(image: image, size: image.size, mediaInfo: mediaInfo) { [weak self] success, segment in
                guard let strongSelf = self else {
                    return
                }
                guard success else {
                    return
                }
                performUIUpdate {
                    strongSelf.clipsController.addNewClip(MediaClip(representativeFrame: image,
                                                                    overlayText: nil,
                                                                    lastFrame: image))
                }
            }
        }
    }

    private func pick(video url: URL) {
        let mediaInfo = TumblrMediaInfo(fromVideoURL: url) ?? TumblrMediaInfo(source: .media_library)
        if currentMode.quantity == .single {
            self.showPreviewWithSegments([CameraSegment.video(url, mediaInfo)])
        }
        else {
            segmentsHandler.addNewVideoSegment(url: url, mediaInfo: mediaInfo)
            performUIUpdate {
                if let image = AVURLAsset(url: url).thumbnail() {
                    self.clipsController.addNewClip(MediaClip(representativeFrame: image,
                                                              overlayText: self.durationStringForAssetAtURL(url),
                                                              lastFrame: self.getLastFrameFrom(url)))
                }
            }
        }
    }

    // MARK: - breakdown
    
    /// This function should be called to stop the camera session and properly breakdown the inputs
    public func cleanup() {
        resetState()
        cameraInputController.cleanup()
        if didRegisterForPhotoLibraryChanges {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }

}

extension CameraController: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard
            let lastMediaPickerFetchResult = lastMediaPickerFetchResult,
            let changeDetails = changeInstance.changeDetails(for: lastMediaPickerFetchResult),
            changeDetails.insertedIndexes?.count == 1,
            changeDetails.removedIndexes?.count == 1
        else {
            return
        }
        fetchMostRecentPhotoLibraryImage(targetSize: mediaPickerThumbnailTargetSize) { image in
            guard let image = image else { return }
            self.modeAndShootController.setMediaPickerButtonThumbnail(image)
        }
    }

    public func resetState() {
        overlayViewController?.dismiss(animated: true, completion: nil)
        clipsController.removeAllClips()
        cameraInputController.deleteAllSegments()
        imagePreviewController.setImagePreview(nil)
    }
}
