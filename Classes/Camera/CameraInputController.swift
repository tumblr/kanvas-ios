//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Default values for the input camera
private struct CameraInputConstants {
    static let sessionQueue: String = "kanvas.camera.sessionQueue"
    static let videoQueue: String = "kanvas.camera.videoQueue"
    static let audioQueue: String = "kanvas.camera.audioQueue"
    static let flashColor = UIColor.white.withAlphaComponent(0.4)
    static let previewBlurAnimationDuration = 0.6
    static let previewVisibleAnimationDuration = 0.4
}

/// The class for controlling the device camera.
/// It directly interfaces with AVFoundation classes to control video / audio input

final class CameraInputController: UIViewController, CameraRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, FilteredInputViewControllerDelegate {

    /// Flag used to indicate that this view controller will be closing, and the capture session should not restart.
    var willCloseSoon = false

    private let targetFrameRate: Int32 = 30
    private let minimumFrameRate: Int32 = 24

    /// The current camera device position
    private(set) var currentCameraPosition: AVCaptureDevice.Position = .back

    /// The type of output being used.
    private(set) var currentCameraOutput: CameraOutput = CameraOutput.video

    /// The current flash mode
    private(set) var flashMode: AVCaptureDevice.FlashMode = .off

    /// The current device corresponding to the current position
    var currentDevice: AVCaptureDevice? {
        switch currentCameraPosition {
        case .front: return frontCamera
        case .back, .unspecified: return rearCamera
        @unknown default:
            return rearCamera
        }
    }

    /// Current applied filter type
    var currentFilterType: FilterType? {
        return filteredInputViewControllerInstance?.currentFilter
    }

    private var filteredInputViewControllerInstance: FilteredInputViewController?
    private var filteredInputViewController: FilteredInputViewController? {
        if filteredInputViewControllerInstance == nil {
            if settings.features.openGLPreview || settings.features.metalPreview {
                filteredInputViewControllerInstance = FilteredInputViewController(delegate: self, settings: settings)
            }
            else {
                filteredInputViewControllerInstance = nil
            }
        }
        filteredInputViewControllerInstance?.view.alpha = 0
        return filteredInputViewControllerInstance
    }
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let previewBlurView = UIVisualEffectView(effect: CameraInputController.blurEffect())
    private let flashLayer = CALayer()
    private let sessionQueue = DispatchQueue(label: CameraInputConstants.sessionQueue)
    private let videoQueue: DispatchQueue = DispatchQueue(label: CameraInputConstants.videoQueue, attributes: [], target: DispatchQueue.global(qos: .userInteractive))
    private let audioQueue: DispatchQueue = DispatchQueue(label: CameraInputConstants.audioQueue, attributes: [])
    private let isSimulator = Device.isRunningInSimulator

    private var settings: CameraSettings
    private var recorderType: CameraRecordingProtocol.Type
    private var segmentsHandler: SegmentsHandlerType

    private var captureSession: AVCaptureSession?
    private var frontCamera: AVCaptureDevice?
    private var rearCamera: AVCaptureDevice?

    private var microphone: AVCaptureDevice?
    private var currentCameraInput: AVCaptureDeviceInput?
    private var currentMicInput: AVCaptureDeviceInput?

    private var photoOutput: AVCapturePhotoOutput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var audioDataOutput: AVCaptureAudioDataOutput?
    private var currentCaptureOutput: AVCaptureOutput? {
        switch currentCameraOutput {
        case .photo: return photoOutput
        case .video: return videoDataOutput
        }
    }
    private(set) var recorder: CameraRecordingProtocol?
    
    /// The delegate methods for zooming and touches
    weak var delegate: CameraInputControllerDelegate?
    
    @available(*, unavailable, message: "use init(defaultFlashOption:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable, message: "use init(defaultFlashOption:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    /// Constructs a CameraInputController that will take care of capturing and showing
    /// the corresponding media content.
    ///
    /// - Parameters:
    ///   - settings: Settings to configure some parameters like: which media is possible
    /// or with what resources should media be captured (for example, flash).
    ///   - recorderClass: Class that will provide a recorder that defines exactly how to record media.
    ///   - segmentsHandlerClass: Class that will provide a segments handler for storing stop
    /// motion segments and constructing final input.
    ///   - delegate: Delegate for input
    public init(settings: CameraSettings, recorderClass: CameraRecordingProtocol.Type, segmentsHandler: SegmentsHandlerType, delegate: CameraInputControllerDelegate? = nil) {
        self.settings = settings
        recorderType = recorderClass
        self.segmentsHandler = segmentsHandler
        self.delegate = delegate
        super.init(nibName: .none, bundle: .none)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func teardownNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appWillResignActive() {
        sessionQueue.async {
            self.captureSession?.stopRunning()
        }
    }

    @objc private func appDidBecomeActive() {
        sessionQueue.async {
            self.captureSession?.startRunning()
        }
    }
    
    deinit {
        teardownNotifications()
    }

    func stopSession() {
        sessionQueue.async {
            self.captureSession?.stopRunning()
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let frameSize = view.frame.size

        // Initialize capture session so captureSession is ensured to be not nil when the view loads.
        createCaptureSession()

        // Create the recorder now, even though the session-based outputs are nil, this helps with testability.
        setupRecorder(self.recorderType, frameSize: frameSize, segmentsHandler: self.segmentsHandler)

        setupGestures()

        if filteredInputViewController != nil {
            setupFilteredPreview()
        }
        else {
            setupPreview()
        }

        setupFlash(defaultOption: settings.preferredFlashOption)

        setupPreviewBlur()

        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard !willCloseSoon else {
            return
        }

        guard !isSimulator else {
            previewBlurView.effect = nil
            return
        }

        setupCaptureSession(frameSize: view.frame.size)

        setupNotifications()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard !isSimulator else {
            return
        }

        stopCaptureSession()

        teardownNotifications()
    }

    func setupCaptureSession(frameSize: CGSize) {
        previewBlurView.effect = CameraInputController.blurEffect()
        let hasFullAccess = delegate?.cameraInputControllerHasFullAccess() ?? true
        guard hasFullAccess else {
            return
        }
        sessionQueue.async { [weak self] in
            self?.createCaptureSession()
            self?.configureSession()
            if let self = self {
                self.setupRecorder(self.recorderType, frameSize: frameSize, segmentsHandler: self.segmentsHandler)
            }
            self?.captureSession?.startRunning()
            performUIUpdate { [weak self] in
                UIView.animate(withDuration: CameraInputConstants.previewBlurAnimationDuration) {
                    self?.previewBlurView.effect = nil
                }
                UIView.animate(withDuration: CameraInputConstants.previewVisibleAnimationDuration) {
                    self?.filteredInputViewControllerInstance?.view.alpha = 1
                    self?.previewLayer.opacity = 1
                }
            }
        }
    }

    func stopCaptureSession() {
        previewBlurView.effect = CameraInputController.blurEffect()
        filteredInputViewControllerInstance?.view.alpha = 0
        previewLayer.opacity = 0
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
        }
        filteredInputViewControllerInstance?.reset()
    }

    func cleanup() {
        guard !isSimulator else { return }

        teardownFilteredPreview()

        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            self?.removeSessionInputsAndOutputs()
            self?.captureSession = nil
        }

        teardownNotifications()
    }

    private static func blurEffect() -> UIBlurEffect {
        return UIBlurEffect(style: .regular)
    }

    /// Configures a capture session. Must be called from the sessionQueue.
    private func configureSession() {
        guard !isSimulator else {
            return
        }
        do {
            captureSession?.beginConfiguration()
            try configureCaptureDevices()
            try configureCameraInputs()
            try configurePhotoOutput()
            try configureVideoDataOutput()
            try configureAudioDataInput()
            try configureAudioDataOutput()
            try configureCurrentOutput()
            captureSession?.commitConfiguration()
            refreshOrientation()
        } catch {
            // this can happen if not all permissions were accepted, should not throw an exception
            captureSession?.commitConfiguration()
            return
        }
    }

    @objc func orientationChanged() {
        refreshOrientation()
    }

    private func refreshOrientation() {
        captureSession?.connections.forEach({ connection in
            connection.videoOrientation = orientation()
        })
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        refreshOrientation()

        stopCaptureSession()
        setupCaptureSession(frameSize: CGSize(width: size.width, height: size.height))
    }


    private func orientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }

    private func setupGestures() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(gesture:))))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinched)))
    }

    private func setupPreview() {
        previewLayer.session = captureSession
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.opacity = 0
        view.layer.addSublayer(previewLayer)
    }

    private func setupFilteredPreview() {
        guard let filteredInputViewController = self.filteredInputViewController else { return }

        if !children.contains(filteredInputViewController) {
            load(childViewController: filteredInputViewController, into: view)
        }
    }

    func teardownFilteredPreview() {
        guard filteredInputViewControllerInstance != nil else { return }
        filteredInputViewControllerInstance?.reset()
        filteredInputViewControllerInstance?.unloadFromParentViewController()
        filteredInputViewControllerInstance = nil
    }

    private func setupPreviewBlur() {
        guard !UIAccessibility.isReduceTransparencyEnabled else { return }

        if !view.subviews.contains(previewBlurView) {
            previewBlurView.backgroundColor = .clear
            previewBlurView.frame = self.view.bounds
            previewBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if isSimulator {
                previewBlurView.effect = nil
            }
            view.addSubview(previewBlurView)
        }
    }

    private func setupFlash(defaultOption: AVCaptureDevice.FlashMode) {
        flashLayer.backgroundColor = CameraInputConstants.flashColor.cgColor
        flashLayer.frame = previewLayer.bounds
        hideFlashLayer()

        previewLayer.addSublayer(flashLayer)
        flashMode = defaultOption
    }

    private func setupRecorder(_ recorderClass: CameraRecordingProtocol.Type, frameSize: CGSize, segmentsHandler: SegmentsHandlerType) {
        let size = recordingDimensions(frameSize: frameSize)
        self.recorder = recorderClass.init(size: size, photoOutput: photoOutput, videoOutput: videoDataOutput, audioOutput: audioDataOutput, recordingDelegate: self, segmentsHandler: segmentsHandler, settings: settings)
    }

    // MARK: - Internal methods

    /// Switches between front and rear camera, if possible
    func switchCameras() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            do {
                try? self?.toggleFrontRearCameras()
                try? self?.configureCurrentOutput()
            }
            self?.captureSession?.startRunning()
        }

        // have to rebuild the filtered input display setup
        filteredInputViewControllerInstance?.reset()
    }

    /// Changes the current output modes corresponding to camera mode
    ///
    /// - Parameter mode: The current camera mode
    /// - throws:
    func configureMode(_ mode: CameraMode) throws {
        switch mode.group {
        case .photo:
            currentCameraOutput = .photo
        case .video, .gif:
            currentCameraOutput = .video
        }
        do { try configureCurrentOutput() } catch {
            // camera could be initialized properly in current mode but failed to switch modes. Should not crash
            NSLog("could not configure for mode \(mode)")
            throw CameraInputError.invalidOperation
        }
    }

    /// Records a gif using the CameraRecordingProtocol type
    ///
    /// - Parameter completion: returns a local file URL if successful
    func takeGif(numberOfFrames: Int, framesPerSecond: Int, completion: @escaping (URL?) -> Void) {
        guard let recorder = recorder else {
            completion(nil)
            return
        }
        addArtificialFlashIfNecessary()
        recorder.takeGifMovie(numberOfFrames: numberOfFrames, framesPerSecond: framesPerSecond, completion: { [weak self] url in
            self?.removeArtificialFlashIfNecessary()
            completion(url)
        })
    }

    /// Takes a photo using the CameraRecordingProtocol type
    ///
    /// - Parameter mode: current camera mode
    /// - Parameter completion: returns a UIImage if successful
    func takePhoto(on mode: CameraMode, completion: @escaping (UIImage?) -> Void) {
        guard let recorder = recorder else {
            completion(nil)
            return
        }
        recorder.takePhoto(on: mode, cameraPosition: currentCameraPosition, completion: { (image) in
            completion(image)
        })
    }

    /// Starts video recording using the CameraRecordingProtocol type
    ///
    /// - Parameter mode: current camera mode
    /// - Returns: return true if successfully started recording
    func startRecording(on mode: CameraMode) -> Bool {
        guard let recorder = self.recorder else { return false }
        startAudioSession()
        addArtificialFlashIfNecessary()
        recorder.startRecordingVideo(on: mode)
        return true
    }

    /// Finishes video recording
    ///
    /// - Parameter completion: returns a local file URL if successful
    func endRecording(completion: @escaping (URL?) -> Void) {
        guard let recorder = recorder else {
            completion(nil)
            return
        }
        recorder.stopRecordingVideo(completion: { [weak self] url in
            self?.removeArtificialFlashIfNecessary()
            self?.stopAudioSession()
            completion(url)
        })
    }

    /// focus the camera on a location
    ///
    /// - Parameter point: should be a normalized point from (0, 0) to (1, 1)
    /// - Throws:
    func focusCamera(point: CGPoint) throws {
        if let device = currentDevice {
            do {
                try device.lockForConfiguration()
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = point
                }
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = point
                }
                if device.isFocusModeSupported(.autoFocus) {
                    device.focusMode = .autoFocus
                }
                device.unlockForConfiguration()
            }
            catch {
                // not sure if all devices have focus / exposure.
                NSLog("unable to focus for current camera")
                throw CameraInputError.inputsAreInvalid
            }
        }
    }

    /// Sets flash mode
    ///
    /// - Parameter on: true to set flash on
    func setFlashMode(on: Bool) {
        flashMode = on ? .on : .off
    }

    /// Alternates the current flash mode settings from on and off
    func toggleFlash() {
        flashMode = .off == flashMode ? .on : .off
    }

    /// Deletes a segment at an index
    ///
    /// - Parameter index: Int
    func deleteSegment(at index: Int) {
        recorder?.deleteSegment(at: index, removeFromDisk: true)
    }

    func deleteAllSegments() {
        recorder?.deleteAllSegments(removeFromDisk: true)
    }

    /// Moves a segment inside the sequence
    ///
    /// - Parameters:
    ///   - originIndex: Int
    ///   - destinationIndex: Int
    func moveSegment(from originIndex: Int, to destinationIndex: Int) {
        guard let recorder = recorder else { return }
        recorder.moveSegment(from: originIndex, to: destinationIndex)
    }
    
    /// The currently recorded segments of images and video
    ///
    /// - Returns: an array of CameraSegment
    func segments() -> [CameraSegment] {
        return recorder?.segments() ?? []
    }

    /// Applies the filter
    func applyFilter(filterType: FilterType) {
        filteredInputViewControllerInstance?.applyFilter(type: filterType)
    }
    
    /// Starts the current audio session. Must be called from the sessionQueue.
    func startAudioSession() {
        guard let captureSession = captureSession, let audioInput = currentMicInput else { return }
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
    }
    
    /// Stops the current audio session. Must be called from the sessionQueue.
    func stopAudioSession() {
        guard let captureSession = captureSession, let audioInput = currentMicInput else { return }
        captureSession.removeInput(audioInput)
    }
    
    // MARK: - private methods

    @objc private func tapped(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        /// normalize this
        let tapPoint = CGPoint(x: point.x / view.frame.size.width, y: point.y / view.frame.size.height)

        // shouldn't crash if focus is not supported
        do { try? focusCamera(point: tapPoint) }
    }

    @objc private func doubleTapped() {
        delegate?.cameraInputControllerShouldResetZoom()
        switchCameras()
    }

    @objc func pinched(_ gesture: UIPinchGestureRecognizer) {
        delegate?.cameraInputControllerPinched(gesture: gesture)
    }

    private func recordingDimensions(frameSize: CGSize) -> CGSize {
        if let formatDescription = currentDevice?.activeFormat.formatDescription {
            let videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            var dimensions = CGSize(width: CGFloat(videoDimensions.height), height: CGFloat(videoDimensions.width))
            if settings.features.scaleMediaToFill {
                // Make recording resolution have the same aspect ratio as the screen
                dimensions.width = dimensions.height * (frameSize.width / frameSize.height)
            }
            return dimensions
        }
        return .zero
    }

    // MARK: - configuring session and devices

    /// Creates a capture session.
    private func createCaptureSession() {
        guard captureSession == nil else {
            return
        }
        captureSession = AVCaptureSession()

        /// if the capture mode is only photo, then the session preset should be photo
        if settings.enabledModes == [.photo] {
            captureSession?.sessionPreset = .photo
        }
    }

    private func configureCaptureDevices() throws {
        let cameraSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)

        let cameras = cameraSession.devices
        guard !cameras.isEmpty else { throw CameraInputError.noCamerasAvailable }

        for camera in cameras {
            switch camera.position {
            case .front:
                frontCamera = camera
            case .back:
                rearCamera = camera
            case .unspecified:
                break // unspecified cameras are not currently supported
            @unknown default:
                break
            }
            if camera.isFocusModeSupported(.continuousAutoFocus) {
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
        
        let microphoneSession =  AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: AVMediaType.audio, position: .unspecified)
        microphone = microphoneSession.devices.first
    }

    /// Configures Camera Inputs. Must be called from the sessionQueue.
    private func configureCameraInputs() throws {
        guard let captureSession = self.captureSession else { throw CameraInputError.captureSessionIsMissing }

        guard let camera = currentDevice else {
            throw CameraInputError.noCamerasAvailable
        }
        let cameraInput = try AVCaptureDeviceInput(device: camera)
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
            currentCameraInput = cameraInput
        }
        else {
            throw CameraInputError.inputsAreInvalid
        }
    }

    /// Must be called from the sessionQueue.
    private func configurePhotoOutput() throws {
        guard let captureSession = self.captureSession else { throw CameraInputError.captureSessionIsMissing }

        self.photoOutput = AVCapturePhotoOutput()
        guard let photoOutput = self.photoOutput else { throw CameraInputError.invalidOperation }

        photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        else { throw CameraInputError.invalidOperation }
    }

    /// Must be called from the sessionQueue.
    private func configureVideoDataOutput() throws {
        guard let captureSession = self.captureSession else { throw CameraInputError.captureSessionIsMissing }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        else { throw CameraInputError.invalidOperation }
        videoDataOutput = videoOutput

        videoDataOutput?.setSampleBufferDelegate(self, queue: videoQueue)
    }

    private func configureAudioDataOutput() throws {
        guard let captureSession = self.captureSession else { throw CameraInputError.captureSessionIsMissing }

        do {
            let audioOutput = AVCaptureAudioDataOutput()
            if captureSession.canAddOutput(audioOutput) {
                captureSession.addOutput(audioOutput)
            }
            else {
                throw CameraInputError.invalidOperation
            }
            audioDataOutput = audioOutput
            audioDataOutput?.setSampleBufferDelegate(self, queue: audioQueue)
        } catch {
            print("audio input failed")
        }
    }
    
    private func configureAudioDataInput() throws {
        guard let microphone = microphone else { return }
        let audioInput = try AVCaptureDeviceInput(device: microphone)
        currentMicInput = audioInput
    }

    private func configureCurrentOutput() throws {
        guard let connection = self.currentCaptureOutput?.connection(with: .video),
              connection.isVideoOrientationSupported,
              connection.isVideoMirroringSupported else { throw CameraInputError.invalidOperation }
        connection.videoOrientation = .portrait
        guard let camera = currentDevice else { throw CameraInputError.noCamerasAvailable }
        connection.isVideoMirrored = camera.position == .front
    }

    private func toggleFrontRearCameras() throws {
        guard let captureSession = self.captureSession else { throw CameraInputError.captureSessionIsMissing }

        guard let currentCameraInput = self.currentCameraInput, captureSession.inputs.contains(currentCameraInput) else { throw CameraInputError.invalidOperation }

        guard let otherCamera = self.currentCameraInput?.device == self.frontCamera ? self.rearCamera : self.frontCamera else {
            // could not switch, but perhaps device only has one camera
            return
        }
        let otherCameraInput = try AVCaptureDeviceInput(device: otherCamera)
        captureSession.removeInput(currentCameraInput)
        if captureSession.canAddInput(otherCameraInput) {
            captureSession.addInput(otherCameraInput)
            self.currentCameraInput = otherCameraInput
            currentCameraPosition = otherCamera == frontCamera ? .front : .back
        }
        else {
            throw CameraInputError.invalidOperation
        }
    }

    // MARK: - flash logic

    private func showFlashLayer() {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        flashLayer.opacity = 1
        CATransaction.commit()
    }

    private func hideFlashLayer() {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        flashLayer.opacity = 0
        CATransaction.commit()
    }

    private func addArtificialFlashIfNecessary() {
        if currentCameraPosition == .front && flashMode == .on {
            showFlashLayer()
        }
    }

    private func removeArtificialFlashIfNecessary() {
        if currentCameraPosition == .front && flashMode == .on {
            hideFlashLayer()
        }
    }

    // MARK: - CameraRecordingDelegate
    // more documentation on the protocol methods can be found in the CameraRecordingDelegate
    func photoSettings(for output: AVCapturePhotoOutput?) -> AVCapturePhotoSettings? {
        let settings = AVCapturePhotoSettings()
#if !targetEnvironment(simulator)
        if output?.supportedFlashModes.contains(.on) == true {
            settings.flashMode = flashMode
        }
#endif
        return settings
    }

    func cameraWillTakeVideo() {
        guard let camera = currentDevice else { return }
        if flashMode == .on {
            if camera.hasTorch && camera.isTorchModeSupported(.on) {
                do {
                    try camera.lockForConfiguration()
                    camera.torchMode = .on
                    camera.unlockForConfiguration()
                } catch {
                    assertionFailure("torch mode failed")
                }
            }
        }
    }

    func cameraWillFinishVideo() {
        guard let camera = currentDevice else { return }
        if camera.hasTorch && camera.torchMode != .off && camera.isTorchModeSupported(.off) {
            do {
                try camera.lockForConfiguration()
                camera.torchMode = .off
                camera.unlockForConfiguration()
            } catch {
                assertionFailure("torch mode failed")
            }
        }
    }

    func cameraDidTakePhoto(image: UIImage?) -> UIImage? {
        let filteredImage = filteredInputViewControllerInstance?.filterImageWithCurrentPipeline(image: image)
        return filteredImage ?? image
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == audioDataOutput {
            recorder?.processAudioSampleBuffer(sampleBuffer)
        }
        else if output == videoDataOutput {
            filteredInputViewControllerInstance?.filterSampleBuffer(sampleBuffer)
            if !(settings.features.openGLCapture || settings.features.metalFilters) {
                recorder?.processVideoSampleBuffer(sampleBuffer)
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var mode: CMAttachmentMode = 0
        let reasonMaybe = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_DroppedFrameReason, attachmentModeOut: &mode)
        guard let reason = reasonMaybe else {
            assertionFailure("CMSampleBuffer was dropped for an unknown reason")
            return
        }
        let reasonString = String(describing: reason)
        print("CMSampleBuffer was dropped for reason: \(reason)")

        // While dropping a sample is usually OK, OutOfBuffers is problematic because it means the CMSampleBuffer is
        // being retained for too long. This is either becuase processing each frame is taking too long, OR
        // CMSampleBuffers are being improperly retained (memory leak). While a blip of OutOfBuffers is probably
        // processing time, a sustained stream of them is a leak. We might have a combination of both :/
        // Anyway, this will help us recover from OutOfBuffers (see method doc for more info)
        if reasonString == (kCMSampleBufferDroppedFrameReason_OutOfBuffers as String) {
            recoverFromDroppedFrameOutOfBuffers()
        }
    }

    /// Recover from dropping a frame when OutOfBuffers is reported
    ///
    /// This is fun. While switching filters, eventually the AVCaptureSession will start spewing
    /// OutOfBuffers DroppedFrameReason, which hangs the camera output. This is due to a memory leak which isn't easily
    /// discoverable, so initially it was addressed by restarting the AVCaptureSession. When done on another queue, this
    /// is really fast on most devices, only noticable with a momentary change of focus, so it was acceptable. However,
    /// it was discovered on an iPhone 6 that OutOfBuffers seemingly happens for other legitimate reasons, and the
    /// AVCaptureSession restarts would take much longer, and sometimes many in a row, making the camera fairly unusable.
    ///
    /// To recover from OutOfBuffers on all devices, we... flip the max framerate between 30fps and 29fps.
    ///
    /// ¯\_(ツ)_/¯
    ///
    /// This works because it causes a configuration change, making the AVCaptureSession recreate its internal
    /// CMSampleBuffer cache.
    func recoverFromDroppedFrameOutOfBuffers() {
        sessionQueue.sync {
            if let session = captureSession, let device = currentDevice {
                do {
                    let currentMaxFrameRate: Int32 = device.activeVideoMaxFrameDuration.timescale
                    let newMaxFrameRate: Int32 = currentMaxFrameRate == targetFrameRate ? targetFrameRate - 1 : targetFrameRate
                    print("Adjusting framerate to recover from OutOfBuffers")
                    session.beginConfiguration()
                    try device.lockForConfiguration()
                    device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: minimumFrameRate)
                    device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: newMaxFrameRate)
                    device.unlockForConfiguration()
                    session.commitConfiguration()
                } catch {
                    assertionFailure("Failed to lock the device for configuration: \(error)")
                }
            }
        }
    }

    // MARK: - FilteredInputViewControllerDelegate
    func filteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {
        if settings.features.openGLCapture || settings.features.metalFilters {
            recorder?.processVideoPixelBuffer(pixelBuffer, presentationTime: presentationTime)
        }
    }

    // MARK: - breakdown
    
    /// Function to remove the current inputs and outputs from the capture session
    func removeSessionInputsAndOutputs() {
        if let input = currentCameraInput {
            captureSession?.removeInput(input)
            currentCameraInput = nil
        }
        if let audioInput = currentMicInput {
            captureSession?.removeInput(audioInput)
            currentMicInput = nil
        }
        if let aPhotoOutput = photoOutput {
            captureSession?.removeOutput(aPhotoOutput)
            photoOutput = nil
        }
        if let aVideoDataOutput = videoDataOutput {
            captureSession?.removeOutput(aVideoDataOutput)
            videoDataOutput = nil
        }
        if let audioOutput = audioDataOutput {
            captureSession?.removeOutput(audioOutput)
            audioDataOutput = nil
        }
    }
}
