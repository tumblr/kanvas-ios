//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

/// A protocol for camera recording callbacks
protocol CameraRecordingDelegate: class {

    /// this is called before a photo is taken. It uses the returned settings (if any) for the current device
    ///
    /// - Returns: AVCapturePhotoSettings for flash, etc
    func photoSettings(for output: AVCapturePhotoOutput?) -> AVCapturePhotoSettings?

    /// this is called before a video is taken. Methods to change UI, update torch, should be called from this method
    func cameraWillTakeVideo()

    /// this is called after a video is taken. Methods to change UI, update torch, should be called from this method
    func cameraWillFinishVideo()
}

/// A protocol adopted by the various capture recorders
protocol CameraRecordingProtocol {

    /// Initializer for the camera
    ///
    /// - Parameters:
    ///   - size: CGSize of the video camera (dimensions)
    ///   - photoOutput: AVCapturePhotoOutput - for taking photos
    ///   - videoOutput: AVCaptureVideoDataOutput - for taking video with CMSampleBuffer
    ///   - audioOutput: AVCaptureAudioDataOutput - for recording the microphone
    ///   - recordingDelegate: delegate for recording methods
    ///   - segmentsHandler: handler for segments and final output creating
    init(size: CGSize,
         photoOutput: AVCapturePhotoOutput?,
         videoOutput: AVCaptureVideoDataOutput?,
         audioOutput: AVCaptureAudioDataOutput?,
         recordingDelegate: CameraRecordingDelegate?,
         segmentsHandler: SegmentsHandlerType)

    /// the recording delegate for callback methods
    var recordingDelegate: CameraRecordingDelegate? { get set }

    /// returns whether the recorder is currently recording video
    ///
    /// - Returns: Bool for state
    func isRecording() -> Bool

    /// returns the currently recorded segments
    ///
    /// - Returns: [CameraSegment]
    func segments() -> [CameraSegment]

    /// adds a segment that is already created
    ///
    /// - Parameter segment: a segment containing an image or a video url
    func addSegment(_ segment: CameraSegment)

    /// returns the destination url of the captured content
    ///
    /// - Returns: URL? can be nil if not currently recording
    func outputURL() -> URL?

    /// starts recording video
    ///
    /// - Returns: returns whether it has successfully started
    func startRecordingVideo()

    /// stops recording video, and exports the recording to a local file
    ///
    /// - Parameter completion: URL of the local video clip, can be nil if erroring
    /// - Returns: Void
    func stopRecordingVideo(completion: @escaping (URL?) -> Void)

    /// cancels the current recording and discards the segment
    func cancelRecording()

    /// takes a photo and appends to the segments.
    ///
    /// - Parameter completion: returns a UIImage if successful
    /// - Returns: Void
    func takePhoto(completion: @escaping (UIImage?) -> Void)

    /// composites a video and exports the resulting file to mp4
    ///
    /// - Parameter completion: Returns a destination URL if successful
    /// - Returns: Void
    func exportRecording(completion: @escaping (URL?) -> Void)

    /// deletes a segment at the selected index
    ///
    /// - Parameter index: location of the segment from `segments`
    /// - Parameter removeFromDisk: whether to also delete the file from disk
    func deleteSegmentAtIndex(_ index: Int, removeFromDisk: Bool)

    /// moves a segment
    ///
    /// - Parameters:
    ///   - originIndex: index at which the segments is right now
    ///   - destinationIndex: index at which we want the segment to be after this
    /// - Returns: Void
    func moveSegment(from originIndex: Int, to destinationIndex: Int)

    /// takes a `boomerang` (but actually is a video recording).
    ///
    /// - Parameter
    ///     useLongerDuration: whether to use a longer than normal duration for recording
    ///     completion: Returns the destination url
    /// - Returns: Void
    func takeGifMovie(useLongerDuration: Bool, completion: @escaping (URL?) -> Void)

    /// cancels current recording and discards all properties
    func reset()

    /// updates the output size of gifs and movies
    ///
    /// - Parameter size: dimensions of video
    func updateOutputSize(_ size: CGSize)

    /// processes the video buffer
    ///
    /// - Parameter sampleBuffer: CMSampleBuffer input to be processed
    func processVideoSampleBuffer(_ sampleBuffer: CMSampleBuffer)

    /// processes the audio buffer
    ///
    /// - Parameter sampleBuffer: CMSampleBuffer input to be processed
    func processAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer)

    /// the duration in seconds of the current clip, if currently recording
    ///
    /// - Returns: can be nil if not recording
    func currentClipDuration() -> TimeInterval?
}
