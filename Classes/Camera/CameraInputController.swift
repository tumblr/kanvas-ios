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
    static let sampleBufferQueue: String = "SampleBufferQueue"
    static let audioQueue: String = "AudioQueue"
    static let flashColor = UIColor.white.withAlphaComponent(0.4)
}

/// The class for controlling the device camera.
/// It directly interfaces with AVFoundation classes to control video / audio input

final class CameraInputController: UIViewController, CameraRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, FilteredInputViewControllerDelegate {

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
        }
    }

    private lazy var filteredInputViewController: FilteredInputViewController? = {
        if settings.features.openGLPreview {
            return FilteredInputViewController(delegate: self)
        }
        else {
            return nil
        }
    }()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let flashLayer = CALayer()
    private let sampleBufferQueue: DispatchQueue = DispatchQueue(label: CameraInputConstants.sampleBufferQueue)
    private let audioQueue: DispatchQueue = DispatchQueue(label: CameraInputConstants.audioQueue, qos: .utility)
    private let isSimulator = TARGET_OS_SIMULATOR != 0

    private var settings: CameraSettings
    private var recorderType: CameraRecordingProtocol.Type
    private var segmentsHandlerType: SegmentsHandlerType.Type

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
    private var recorder: CameraRecordingProtocol?
    private var filterViewNeedsReset: Bool = false
    
    /// The delegate methods for zooming and touches
    var delegate: CameraInputControllerDelegate?
    
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
    public init(settings: CameraSettings, recorderClass: CameraRecordingProtocol.Type, segmentsHandlerClass: SegmentsHandlerType.Type, delegate: CameraInputControllerDelegate? = nil) {
        self.settings = settings
        recorderType = recorderClass
        segmentsHandlerType = segmentsHandlerClass
        self.delegate = delegate
        super.init(nibName: .none, bundle: .none)
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appWillResignActive() {
        captureSession?.stopRunning()
    }

    @objc private func appDidBecomeActive() {
        captureSession?.startRunning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        createCaptureSession()
        configureSession()
        setupGestures()

        if filteredInputViewController != nil {
            setupFilteredPreview()
        }
        else {
            setupPreview()
        }

        setupFlash(defaultOption: settings.preferredFlashOption)
        setupRecorder(recorderType, segmentsHandlerType: segmentsHandlerType)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !isSimulator else { return }

        captureSession?.startRunning()

        // have to rebuild the filtered input display setup
        if filterViewNeedsReset {
            filteredInputViewController?.reset()
        }

        filterViewNeedsReset = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        guard !isSimulator else { return }

        captureSession?.stopRunning()
        filterViewNeedsReset = true
    }

    func cleanup() {
        guard !isSimulator else { return }

        filteredInputViewController?.cleanup()
        removeSessionInputsAndOutputs()
        captureSession?.stopRunning()
        captureSession = nil
    }

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
            try configureAudioDataOutput()
            try configureCurrentOutput()
            captureSession?.commitConfiguration()
        } catch {
            // this can happen if not all permissions were accepted, should not throw an exception
            captureSession?.commitConfiguration()
            return
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
        view.layer.addSublayer(previewLayer)
    }

    private func setupFilteredPreview() {
        guard let filteredInputViewController = self.filteredInputViewController else { return }

        load(childViewController: filteredInputViewController, into: view)
    }

    private func setupFlash(defaultOption: AVCaptureDevice.FlashMode) {
        flashLayer.backgroundColor = CameraInputConstants.flashColor.cgColor
        flashLayer.frame = previewLayer.bounds
        hideFlashLayer()

        previewLayer.addSublayer(flashLayer)
        flashMode = defaultOption
    }

    private func setupRecorder(_ recorderClass: CameraRecordingProtocol.Type, segmentsHandlerType: SegmentsHandlerType.Type) {
        let size = currentResolution()
        self.recorder = recorderClass.init(size: size, photoOutput: photoOutput, videoOutput: videoDataOutput, audioOutput: audioDataOutput, recordingDelegate: self, segmentsHandler: segmentsHandlerType.init())
    }

    // MARK: - Internal methods

    /// Switches between front and rear camera, if possible
    func switchCameras() {
        captureSession?.stopRunning()
        do {
            try? toggleFrontRearCameras()
            try? configureCurrentOutput()
        }
        captureSession?.startRunning()

        // have to rebuild the filtered input display setup
        filteredInputViewController?.reset()
    }

    /// Changes the current output modes corresponding to camera mode
    ///
    /// - Parameter mode: The current camera mode
    /// - throws:
    func configureMode(_ mode: CameraMode) throws {
        switch mode {
        case .photo:
            currentCameraOutput = .photo
        case .gif, .stopMotion:
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
    func takeGif(useLongerDuration: Bool = false, completion: @escaping (URL?) -> Void) {
        guard let recorder = recorder else {
            completion(nil)
            return
        }
        addArtificialFlashIfNecessary()
        recorder.takeGifMovie(useLongerDuration: useLongerDuration, completion: { [weak self] url in
            self?.removeArtificialFlashIfNecessary()
            completion(url)
        })
    }

    /// Takes a photo using the CameraRecordingProtocol type
    ///
    /// - Parameter completion: returns a UIImage if successful
    func takePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let recorder = recorder else {
            completion(nil)
            return
        }
        recorder.takePhoto(cameraPosition: currentCameraPosition, completion: { (image) in
            completion(image)
        })
    }

    /// Starts video recording using the CameraRecordingProtocol type
    ///
    /// - Returns: return true if successfully started recording
    func startRecording() -> Bool {
        guard let recorder = self.recorder else { return false }
        addArtificialFlashIfNecessary()
        recorder.startRecordingVideo()
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
    
    private func currentResolution() -> CGSize {
        var resolution = CGSize(width: 0, height: 0)
        if let formatDescription = currentDevice?.activeFormat.formatDescription {
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
            resolution = CGSize(width: CGFloat(dimensions.height), height: CGFloat(dimensions.width))
        }

        return resolution
    }

    // MARK: - configuring session and devices
    
    private func createCaptureSession() {
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
            }
            if camera.isFocusModeSupported(.continuousAutoFocus) {
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
        currentCameraPosition = rearCamera != nil ? .back : .front

        let microphoneSession =  AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: AVMediaType.audio, position: .unspecified)
        microphone = microphoneSession.devices.first
    }

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

        videoDataOutput?.setSampleBufferDelegate(self, queue: sampleBufferQueue)
    }

    private func configureAudioDataOutput() throws {
        guard let captureSession = self.captureSession, let microphone = microphone else { throw CameraInputError.captureSessionIsMissing }

        do {
            let audioInput = try AVCaptureDeviceInput(device: microphone)
            currentMicInput = audioInput
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
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
        if output?.supportedFlashModes.contains(.on) == true {
            settings.flashMode = flashMode
        }
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

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == audioDataOutput {
            recorder?.processAudioSampleBuffer(sampleBuffer)
        }
        else if output == videoDataOutput {
            filteredInputViewController?.filterSampleBuffer(sampleBuffer)
            recorder?.processVideoSampleBuffer(sampleBuffer)
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // dropping a sample should be okay here, processor could be busy
        var mode: CMAttachmentMode = 0
        let reason = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_DroppedFrameReason, attachmentModeOut: &mode)
        print("CMSampleBuffer was dropped for reason: \(String(describing: reason))")
    }
    
    // MARK: - FilteredInputViewControllerDelegate
    func filteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {

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
