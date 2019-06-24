//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit
import MobileCoreServices

// Media wrapper for media generated from the CameraController
public enum KanvasCameraMedia {
    case image(URL)
    case video(URL)
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
    func didCreateMedia(media: KanvasCameraMedia?, error: Error?)

    /**
     A function that is called when the main camera dismiss button is pressed
     */
    func dismissButtonPressed()
    
    /// Called after the welcome tooltip is dismissed
    func didDismissWelcomeTooltip()
    
    /// Called to ask if welcome tooltip should be shown
    ///
    /// - Returns: Bool for tooltip
    func cameraShouldShowWelcomeTooltip() -> Bool
}

// A controller that contains and layouts all camera handling views and controllers (mode selector, input, etc).
public class CameraController: UIViewController, MediaClipsEditorDelegate, CameraPreviewControllerDelegate, EditorControllerDelegate, CameraZoomHandlerDelegate, OptionsControllerDelegate, ModeSelectorAndShootControllerDelegate, CameraViewDelegate, CameraInputControllerDelegate, FilterSettingsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// The delegate for camera callback methods
    public weak var delegate: CameraControllerDelegate?

    private lazy var options: [[Option<CameraOption>]] = {
        return getOptions(from: self.settings)
    }()
    private lazy var cameraView: CameraView = {
        let view = CameraView(numberOfOptionRows: CGFloat(options.count))
        view.delegate = self
        return view
    }()
    private lazy var modeAndShootController: ModeSelectorAndShootController = {
        let controller = ModeSelectorAndShootController(settings: self.settings)
        controller.delegate = self
        return controller
    }()
    private lazy var topOptionsController: OptionsController<CameraController> = {
        let controller = OptionsController<CameraController>(options: options, spacing: CameraConstants.optionHorizontalMargin)
        controller.delegate = self
        return controller
    }()
    private lazy var clipsController: MediaClipsEditorViewController = {
        let controller = MediaClipsEditorViewController()
        controller.delegate = self
        return controller
    }()

    private lazy var cameraInputController: CameraInputController = {
        let controller = CameraInputController(settings: self.settings, recorderClass: self.recorderClass, segmentsHandlerClass: self.segmentsHandlerClass, delegate: self)
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
    
    private let settings: CameraSettings
    private let analyticsProvider: KanvasCameraAnalyticsProvider?
    private var currentMode: CameraMode
    private var isRecording: Bool
    private var disposables: [NSKeyValueObservation] = []
    private var recorderClass: CameraRecordingProtocol.Type
    private var segmentsHandlerClass: SegmentsHandlerType.Type
    private let cameraZoomHandler: CameraZoomHandler

    /// Constructs a CameraController that will record from the device camera
    /// and export the result to the device, saving to the phone all in between information
    /// needed to attain the final output.
    ///
    /// - Parameter settings: Settings to configure in which ways should the controller
    /// interact with the user, which options should the controller give the user
    /// and which should be the result of the interaction.
    ///   - analyticsProvider: An class conforming to KanvasCameraAnalyticsProvider
    convenience public init(settings: CameraSettings, analyticsProvider: KanvasCameraAnalyticsProvider?) {
        self.init(settings: settings, recorderClass: CameraRecorder.self, segmentsHandlerClass: CameraSegmentHandler.self, analyticsProvider: analyticsProvider)
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
         analyticsProvider: KanvasCameraAnalyticsProvider?) {
        self.settings = settings
        currentMode = settings.initialMode
        isRecording = false
        self.recorderClass = recorderClass
        self.segmentsHandlerClass = segmentsHandlerClass
        self.analyticsProvider = analyticsProvider
        cameraZoomHandler = CameraZoomHandler(analyticsProvider: analyticsProvider)
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

    override public var prefersStatusBarHidden: Bool {
        return true
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    /// Requests permissions for video
    ///
    /// - Parameter completion: boolean on whether access was granted
    public func requestAccess(_ completion: ((_ granted: Bool) -> ())?) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (videoGranted) -> Void in
            performUIUpdate {
                completion?(videoGranted)
            }
        })
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
        cameraView.addModeView(modeAndShootController.view)
        cameraView.addClipsView(clipsController.view)
        cameraView.addCameraInputView(cameraInputController.view)
        cameraView.addOptionsView(topOptionsController.view)
        cameraView.addImagePreviewView(imagePreviewController.view)
        if settings.features.cameraFilters {
            cameraView.addFiltersView(filterSettingsController.view)
        }
        bindMediaContentAvailable()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if delegate?.cameraShouldShowWelcomeTooltip() == true {
            showWelcomeTooltip()
        }
    }

    // MARK: - navigation
    
    private func showPreviewWithSegments(_ segments: [CameraSegment]) {
        cameraInputController.stopSession()
        let controller = createNextStepViewController(segments)
        self.present(controller, animated: true)
    }
    
    private func createNextStepViewController(_ segments: [CameraSegment]) -> UIViewController {
        if settings.features.editor {
            return createEditorViewController(segments)
        }
        else {
            return createPreviewViewController(segments)
        }
    }
    
    private func createEditorViewController(_ segments: [CameraSegment]) -> EditorViewController {
        let controller = EditorViewController(settings: settings, segments: segments, assetsHandler: segmentsHandlerClass.init(), cameraMode: currentMode)
        controller.delegate = self
        return controller
    }
    
    private func createPreviewViewController(_ segments: [CameraSegment]) -> CameraPreviewViewController {
        let controller = CameraPreviewViewController(settings: settings, segments: segments, assetsHandler: segmentsHandlerClass.init(), cameraMode: currentMode)
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
    class func saveImageToFile(_ image: UIImage?, info: MediaInfo) -> URL? {
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
                MediaMetadata.write(mediaInfo: info, toImage: fileURL as NSURL)
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

    private func takeGif(useLongerDuration: Bool = false) {
        guard !isRecording else { return }
        updatePhotoCaptureState(event: .started)
        cameraInputController.takeGif(useLongerDuration: useLongerDuration, completion: { [weak self] url in
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
                    let segment = CameraSegment.video(url)
                    strongSelf.showPreviewWithSegments([segment])
                }
            }
        })
    }
    
    private func takePhoto() {
        guard !isRecording else { return }
        updatePhotoCaptureState(event: .started)
        cameraInputController.takePhoto(completion: { [weak self] image in
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
                    if strongSelf.currentMode == .photo {
                        strongSelf.showPreviewWithSegments([CameraSegment.image(image, nil)])
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
        }
        // If it finished recording, then there is at least one clip and button shouldn't be shown.
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
        disposables.append(clipsController.observe(\.hasClips) { [unowned self] object, _ in
            performUIUpdate {
                self.updateUI(forClipsPresent: object.hasClips)
            }
        })
        updateUI(forClipsPresent: clipsController.hasClips)
    }
    
    // MARK: - CameraViewDelegate

    func closeButtonPressed() {
        modeAndShootController.dismissTooltip()
        if clipsController.hasClips {
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
        if mode == .stopMotion {
            cameraZoomHandler.setZoom(point: currentPoint, gesture: gesture)
        }
    }

    func didOpenMode(_ mode: CameraMode, andClosed oldMode: CameraMode?) {
        updateMode(mode)
    }

    func didTapForMode(_ mode: CameraMode) {
        switch mode {
        case .gif:
            takeGif()
        case .photo:
            takePhoto()
        case .stopMotion:
            takePhoto()
        }
    }

    func didStartPressingForMode(_ mode: CameraMode) {
        switch mode {
        case .gif:
            takeGif(useLongerDuration: true)
        case .stopMotion:
            let _ = cameraInputController.startRecording()
            performUIUpdate { [weak self] in
                self?.updateRecordState(event: .started)
            }
        default: break
        }
    }

    func didEndPressingForMode(_ mode: CameraMode) {
        switch mode {
        case .stopMotion:
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
                    if let url = url, let image = AVURLAsset(url: url).thumbnail() {
                        strongSelf.clipsController.addNewClip(MediaClip(representativeFrame: image,
                                                                        overlayText: strongSelf.durationStringForAssetAtURL(url),
                                                                        lastFrame: strongSelf.getLastFrameFrom(url)))
                    }
                    strongSelf.updateRecordState(event: .ended)
                }
            })
        default: break
        }
    }
    
    func didDropToDelete(_ mode: CameraMode) {
        switch mode {
        case .stopMotion:
            clipsController.removeDraggingClip()
        default: break
        }
    }
    
    func didDismissWelcomeTooltip() {
        delegate?.didDismissWelcomeTooltip()
    }

    func didTapMediaPickerButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = false
        imagePickerController.mediaTypes = ["\(kUTTypeMovie)", "\(kUTTypeImage)"]
        present(imagePickerController, animated: true, completion: nil)
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
        modeAndShootController.enableShootButtonUserInteraction(true)
        performUIUpdate { [weak self] in
            self?.cameraView.updateUI(forDraggingClip: true)
            self?.modeAndShootController.showTrashClosed(true)
            self?.clipsController.hidePreviewButton()
        }
    }

    func mediaClipFinishedMoving() {
        analyticsProvider?.logMovedClip()
        let filterSelectorVisible = filterSettingsController.isFilterSelectorVisible()
        modeAndShootController.enableShootButtonUserInteraction(!filterSelectorVisible)
        performUIUpdate { [weak self] in
            self?.cameraView.updateUI(forDraggingClip: false)
            self?.modeAndShootController.showTrashClosed(false)
            self?.clipsController.showPreviewButton()
        }
    }

    func mediaClipWasDeleted(at index: Int) {
        cameraInputController.deleteSegment(at: index)
        let filterSelectorVisible = filterSettingsController.isFilterSelectorVisible()
        modeAndShootController.enableShootButtonUserInteraction(!filterSelectorVisible)
        performUIUpdate { [weak self] in
            self?.cameraView.updateUI(forDraggingClip: false)
            self?.modeAndShootController.showTrashOpened(false)
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
        if let videoURL = url {
            let asset = AVURLAsset(url: videoURL)
            analyticsProvider?.logConfirmedMedia(mode: currentMode, clipsCount: cameraInputController.segments().count, length: CMTimeGetSeconds(asset.duration))
        }
        performUIUpdate { [weak self] in
            self?.cameraInputController.willCloseSoon = true
            self?.delegate?.didCreateMedia(media: url.map { .video($0) }, error: url != nil ? nil : CameraControllerError.exportFailure)
        }
    }

    func didFinishExportingImage(image: UIImage?) {
        analyticsProvider?.logConfirmedMedia(mode: currentMode, clipsCount: 1, length: 0)
        if let url = CameraController.saveImageToFile(image, info: .kanvas) {
            performUIUpdate { [weak self] in
                self?.delegate?.didCreateMedia(media: .image(url), error: nil)
            }
        }
        else {
            performUIUpdate { [weak self] in
                self?.delegate?.didCreateMedia(media: nil, error: CameraControllerError.exportFailure)
            }
        }
    }

    func dismissButtonPressed() {
        analyticsProvider?.logPreviewDismissed()
        performUIUpdate { [weak self] in
            self?.dismiss(animated: true)
        }
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
    
    // MARK: - FilterSettingsControllerDelegate
    
    func didSelectFilter(_ filterItem: FilterItem) {
        cameraInputController.applyFilter(filterType: filterItem.type)
        analyticsProvider?.logFilterSelected(filterType: filterItem.type)
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
        modeAndShootController.dismissTooltip()
    }

    // MARK: - UIImagePickerControllerDelegate

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        let imageMaybe = info[.originalImage] as? UIImage
        let mediaURLMaybe = info[.mediaURL] as? URL

        if let image = imageMaybe {
            pick(image: image)
        }
        if let mediaURL = mediaURLMaybe {
            pick(video: mediaURL)
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func pick(image: UIImage) {
        performUIUpdate {
            if self.currentMode == .photo {
                self.showPreviewWithSegments([CameraSegment.image(image, nil)])
            }
            else {
                self.clipsController.addNewClip(MediaClip(representativeFrame: image,
                                                          overlayText: nil,
                                                          lastFrame: image))
            }
        }
    }

    func pick(video url: URL) {
        if let recorder = self.cameraInputController.recorder as? CameraRecorder {
            recorder.segmentsHandler.addNewVideoSegment(url: url)
        }
        performUIUpdate {
            if let image = AVURLAsset(url: url).thumbnail() {
                self.clipsController.addNewClip(MediaClip(representativeFrame: image,
                                                          overlayText: self.durationStringForAssetAtURL(url),
                                                          lastFrame: self.getLastFrameFrom(url)))
            }
        }
    }
    
    // MARK: - breakdown
    
    /// This function should be called to stop the camera session and properly breakdown the inputs
    public func cleanup() {
        cameraInputController.cleanup()
    }
}
