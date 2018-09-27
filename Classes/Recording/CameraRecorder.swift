//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit
import VideoToolbox

/// Default values for the camera recorder
private struct CameraRecordingConstants {
    /// queue for exporting
    static let PrepareQueue: String = "PrepareQueue"
}

/// An implementation of a CameraRecordingProtocol without filters

final class CameraRecorder: NSObject {
    weak var recordingDelegate: CameraRecordingDelegate?

    private var url: URL?
    private var size: CGSize

    private var assetWriter: AVAssetWriter?
    private var assetWriterVideoInput: AVAssetWriterInput?
    private var assetWriterAudioInput: AVAssetWriterInput?
    private var assetWriterPixelBufferInput: AVAssetWriterInputPixelBufferAdaptor?

    private let photoOutput: AVCapturePhotoOutput?
    private let videoOutput: AVCaptureVideoDataOutput?
    private let audioOutput: AVCaptureAudioDataOutput?

    private var currentVideoSampleBuffer: CMSampleBuffer?
    private var currentAudioSampleBuffer: CMSampleBuffer?

    private var currentRecordingMode: CameraMode
    private let segmentsHandler: SegmentsHandlerType

    private let photoOutputHandler: PhotoOutputHandler
    private let gifVideoOutputHandler: GifVideoOutputHandler
    private let videoOutputHandler: VideoOutputHandler

    private var takingPhoto: Bool = false
    
    required init(size: CGSize,
                  photoOutput: AVCapturePhotoOutput?,
                  videoOutput: AVCaptureVideoDataOutput?,
                  audioOutput: AVCaptureAudioDataOutput?,
                  recordingDelegate: CameraRecordingDelegate?,
                  segmentsHandler: SegmentsHandlerType) {
        self.size = size

        photoOutputHandler = PhotoOutputHandler(photoOutput: photoOutput)
        gifVideoOutputHandler = GifVideoOutputHandler(videoOutput: videoOutput)
        videoOutputHandler = VideoOutputHandler()

        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        self.audioOutput = audioOutput
        self.recordingDelegate = recordingDelegate
        self.segmentsHandler = segmentsHandler

        currentRecordingMode = .stopMotion

        super.init()

        setupNotifications()
    }

    /// This helper function sets up an asset writer at the url. If running on simulator or if devices are not available, it should return without setting up any further
    ///
    /// - Parameter url: the output url for the exported mp4
    private func setupAssetWriter(url: URL?) {
        guard let url = url, size.width != 0, size.height != 0 else { return }
        do {
            assetWriter = try AVAssetWriter(outputURL: url, fileType: AVFileType.mp4)
        } catch {
            NSLog("failed to setup asset writer")
            return
        }
        self.url = url

        let videoOutputSettings: [String: Any] = segmentsHandler.videoOutputSettingsForSize(size: size)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        
        let sourcePixelBufferAttributes: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: size.width, kCVPixelBufferHeightKey as String: size.height]

        assetWriterPixelBufferInput = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
        if assetWriter?.canAdd(videoInput) == true {
            assetWriter?.add(videoInput)
        }

        assetWriterVideoInput = videoInput
        setupAudioForAssetWriter()
    }

    private func setupAudioForAssetWriter() {
        let sampleRate = AVAudioSession.sharedInstance().preferredSampleRate
        guard sampleRate != 0 else {
            NSLog("should not setup up the audio asset writer if no preferred sample rate found")
            return
        }
        var audioChannelLayout: AudioChannelLayout = AudioChannelLayout()
        memset(&audioChannelLayout, 0, MemoryLayout<AudioChannelLayout>.size)
        audioChannelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Mono
        let data = NSData(bytes: &audioChannelLayout, length: MemoryLayout<AudioChannelLayout>.size)

        let audioOutputSettings: [String: Any] = [AVFormatIDKey as String: kAudioFormatMPEG4AAC, AVNumberOfChannelsKey as String: 1, AVSampleRateKey as String: sampleRate, AVEncoderBitRateKey as String: 64000, AVChannelLayoutKey as String: data]
        assetWriterAudioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        assetWriterAudioInput?.expectsMediaDataInRealTime = true
        if let audioInput = assetWriterAudioInput, assetWriter?.canAdd(audioInput) == true {
            assetWriter?.add(audioInput)
        }
    }

    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func appWillResignActive() {
        if isRecording() {
            switch currentRecordingMode {
            case .gif:
                cancelGif()
            case .stopMotion:
                stopRecordingVideo(completion: { _ in })
            default:
                break
            }
        }
    }
    
    // MARK: - private gif creation logic

    private func cancelGif() {
        gifVideoOutputHandler.cancelGif()
    }
}

// MARK: - CameraRecordingProtocol

extension CameraRecorder: CameraRecordingProtocol {

    func addSegment(_ segment: CameraSegment) {
        segmentsHandler.addSegment(segment)
    }

    func updateOutputSize(_ size: CGSize) {
        guard !isRecording() else {
            return
        }
        self.size = size
    }

    func isRecording() -> Bool {
        switch currentRecordingMode {
        case .stopMotion:
            return videoOutputHandler.recording
        case .photo:
            return takingPhoto
        case .gif:
            return gifVideoOutputHandler.recording
        }
    }

    func segments() -> [CameraSegment] {
        return segmentsHandler.segments
    }

    func outputURL() -> URL? {
        return url
    }

    func cancelRecording() {
        if isRecording() {
            assetWriter?.cancelWriting()
        }
    }

    // MARK: - video
    func startRecordingVideo() {
        if isRecording() {
            return
        }
        currentRecordingMode = .stopMotion
        recordingDelegate?.cameraWillTakeVideo()

        setupAssetWriter(url: NSURL.createNewVideoURL())
        guard let assetWriter = assetWriter, let pixelBufferAdaptor = assetWriterPixelBufferInput else {
            return
        }
        videoOutputHandler.startRecordingVideo(assetWriter: assetWriter, pixelBufferAdaptor: pixelBufferAdaptor, audioInput: assetWriterAudioInput)
    }

    func stopRecordingVideo(completion: @escaping (URL?) -> Void) {
        videoOutputHandler.stopRecordingVideo { [weak self] success in
            if let strongSelf = self {
                strongSelf.recordingDelegate?.cameraWillFinishVideo()
                if success, let url = strongSelf.url {
                    strongSelf.segmentsHandler.addNewVideoSegment(url: url)
                    completion(url)
                }
                else {
                    completion(nil)
                }
            }
        }
    }

    func takePhoto(completion: @escaping (UIImage?) -> Void) {
        guard isRecording() == false else {
            return
        }
        
        currentRecordingMode = .photo

        let settings = recordingDelegate?.photoSettingsForCamera
        takingPhoto = true
        photoOutputHandler.takePhoto(settings: settings ?? AVCapturePhotoSettings()) { [unowned self] image in
            self.takingPhoto = false
            guard let image = image else {
                completion(nil)
                return
            }
            self.segmentsHandler.addNewImageSegment(image: image, size: self.size, completion: { (success, _) in
                completion(success ? image : nil)
            })
        }
    }

    func exportRecording(completion: @escaping (URL?) -> Void) {
        segmentsHandler.exportVideo(completion: { url in
            completion(url)
        })
    }

    func deleteSegmentAtIndex(_ index: Int, removeFromDisk: Bool = true) {
        segmentsHandler.deleteSegment(index: index, removeFromDisk: removeFromDisk)
    }

    // MARK: - gif
    func takeGifMovie(completion: @escaping (URL?) -> Void) {
        if isRecording() {
            completion(nil)
            return
        }
        currentRecordingMode = .gif
        recordingDelegate?.cameraWillTakeVideo()

        setupAssetWriter(url: NSURL.createNewVideoURL())

        gifVideoOutputHandler.takeGifMovie(assetWriter: assetWriter, pixelBufferAdaptor: assetWriterPixelBufferInput, videoInput: assetWriterVideoInput, audioInput: assetWriterAudioInput) { [unowned self] success in
            self.recordingDelegate?.cameraWillFinishVideo()
            completion(success ? self.url : nil)
        }
    }

    func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        self.currentVideoSampleBuffer = sampleBuffer
        switch currentRecordingMode {
        case .stopMotion:
            videoOutputHandler.processVideoSampleBuffer(sampleBuffer)
        case .gif:
            gifVideoOutputHandler.processVideoSampleBuffer(sampleBuffer)
        default: break
        }
    }

    func processAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        self.currentAudioSampleBuffer = sampleBuffer
        switch currentRecordingMode {
        case .stopMotion:
            videoOutputHandler.processAudioSampleBuffer(sampleBuffer)
        default: break
        }
    }

    func reset() {
        setupAssetWriter(url: NSURL.createNewVideoURL())
        segmentsHandler.reset(removeFromDisk: true)
    }

    func currentClipDuration() -> TimeInterval? {
        guard currentRecordingMode == .stopMotion else {
            return nil
        }
        return videoOutputHandler.currentClipDuration()
    }
}
