//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

/// A container for segments

struct CameraSegment {
    var image: UIImage? = nil
    var videoURL: URL? = nil

    init(image: UIImage? = nil, videoURL: URL? = nil) {
        self.image = image
        self.videoURL = videoURL
    }
}

/// A class to handle the various segments of a stop motion video, and also creates the final output

final class CameraSegmentHandler {
    var segments: [CameraSegment] = []
    private var assetWriter: AVAssetWriter?
    private var assetWriterVideoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?

    /// Creates a new CameraSegment from a video url and appends to segments
    ///
    /// - Parameter url: the local url of the video
    /// - Returns: success if file exists and is appended
    @discardableResult func addNewVideoSegment(url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else { return false }
        let segment = CameraSegment(videoURL: url)
        segments.append(segment)
        return true
    }

    /// Creates a video from a UIImage representation and appends as a CameraSegment
    ///
    /// - Parameters:
    ///   - image: UIImage
    ///   - size: size (resolution) of the video
    ///   - completion: completion handler, success bool and URL of video
    func addNewImageSegment(image: UIImage, size: CGSize, completion: @escaping (Bool, CameraSegment?) -> Void) {
        guard let url = setupAssetWriter(size: size) else {
            completion(false, nil)
            return
        }

        let bufferAttributes: [String: Any] = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA, String(kCVPixelBufferCGBitmapContextCompatibilityKey): true, String(kCVPixelBufferCGImageCompatibilityKey): true, String(kCVPixelBufferWidthKey): size.width, String(kCVPixelBufferHeightKey): size.height]
        guard let assetWriter = assetWriter, let input = assetWriterVideoInput else {
            completion(false, nil)
            return
        }
        assetWriter.add(input)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: bufferAttributes)
        createVideoFromImage(image: image, assetWriter: assetWriter, adaptor: adaptor, input: input, completion: { success in
            if success {
                let segment = CameraSegment(image: image, videoURL: url)
                self.segments.append(segment)
                completion(success, segment)
            }
            else {
                completion(false, nil)
            }
        })
    }

    /// Deletes a segment
    ///
    /// - Parameter index: the index of the segment to be deleted
    func deleteSegment(index: Int, removeFromDisk: Bool? = true) {
        guard index < segments.count else { return }
        if removeFromDisk == true {
            let segment = segments[index]
            if let url = segment.videoURL {
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: url.path) {
                    do {
                        try fileManager.removeItem(at: url)
                    } catch {
                        NSLog("failed to remove item at \(url)")
                    }
                }
            }
        }
        segments.remove(at: index)
    }

    /// an approximation of the total duration. calculating the exact duration would have to be asynchronous
    ///
    /// - Returns: seconds of total recorded video + photos
    func currentTotalDuration() -> TimeInterval {
        var totalDuration: CMTime = kCMTimeZero
        for segment in segments {
            if let segmentURL = segment.videoURL {
                let asset = AVURLAsset(url: segmentURL)
                totalDuration = CMTimeAdd(totalDuration, asset.duration)
            }
            else if let _ = segment.image {
                totalDuration = CMTimeAdd(totalDuration, KanvasCameraTimes.StopMotionFrameTime)
            }
        }
        return CMTimeGetSeconds(totalDuration)
    }

    /// This functions exports the complete final video to a local resource.
    ///
    /// - Parameter completion: returns a local video URL if merged successfully
    func exportVideo(completion: @escaping (URL?) -> Void) {
        CameraSegmentHandler.mergeAssets(segments: segments, completion: completion)
    }
    
    /// This removes all segments from disk and memory
    func reset(removeFromDisk: Bool? = true) {
        if removeFromDisk == true {
            let fileManager = FileManager.default
            for segment in segments {
                if let url = segment.videoURL, fileManager.fileExists(atPath: url.path) {
                    do {
                        try fileManager.removeItem(at: url)
                    } catch { }
                }
            }
        }
        segments.removeAll()
    }
    
    /// concatenates all of the videos in the segments
    ///
    /// - Parameters:
    ///   - segments: the CameraSegments to be merged
    ///   - completion: returns a local video URL if merged successfully
    class func mergeAssets(segments: [CameraSegment], completion: @escaping (URL?) -> Void) {
        let mixComposition = AVMutableComposition()
        var videoCompTrack, audioCompTrack: AVMutableCompositionTrack?
        var insertTime = kCMTimeZero
        
        for segment in segments {
            guard let segmentURL = segment.videoURL else { continue }
            let urlAsset = AVURLAsset(url: segmentURL)
            var videoDuration: CMTime = kCMTimeZero
            
            if let videoTrack = urlAsset.tracks(withMediaType: .video).first {
                videoCompTrack = videoCompTrack ?? mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                addTrack(assetTrack: videoTrack, compositionTrack: videoCompTrack, time: insertTime)
                videoDuration = videoTrack.timeRange.duration
            }
            if let audioTrack = urlAsset.tracks(withMediaType: .audio).first {
                audioCompTrack = audioCompTrack ?? mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                
                var audioTimeRange = audioTrack.timeRange
                if CMTimeCompare(audioTrack.timeRange.duration, videoDuration) == 1 {
                    audioTimeRange = CMTimeRangeMake(audioTimeRange.start, videoDuration); // crop audio to video range
                }
                addTrack(assetTrack: audioTrack, compositionTrack: audioCompTrack, time: insertTime)
            }
            insertTime = CMTimeAdd(insertTime, videoDuration)
        }
        exportComposition(composition: mixComposition, completion: { url in
            completion(url)
        })
    }

    /// Video output settings, used by internal classes for recording and exporting
    ///
    /// - Parameter size: dimensions of the video output
    /// - Returns: Dictionary of settings
    class func videoOutputSettingsForSize(size: CGSize) -> [String: Any] {
        let width = Int(size.width)
        let height = Int(size.height)
        let outputSettings: [String: Any] = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: width, AVVideoHeightKey: height]
        return outputSettings
    }
}

/// helper functions
private extension CameraSegmentHandler {

    /// Sets up the asset writer for video creation
    ///
    /// - Parameter size: resolution of video
    /// - Returns: URL?: the url of the local video
    func setupAssetWriter(size: CGSize) -> URL? {
        guard let url = NSURL.createNewVideoURL() else {
            return nil
        }
        do { assetWriter = try AVAssetWriter(outputURL: url, fileType: AVFileType.mp4) } catch {
            return nil
        }
        let outputSettings: [String: Any] = CameraSegmentHandler.videoOutputSettingsForSize(size: size)
        assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
        assetWriterVideoInput?.expectsMediaDataInRealTime = true

        return url
    }

    /// private method for exporting a composition after all tracks have been added
    ///
    /// - Parameters:
    ///   - composition: the final composition to be exported
    ///   - completion: url of the local video
    class func exportComposition(composition: AVMutableComposition, completion: @escaping (URL?) -> Void) {
        guard let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else { return }
        assetExport.outputFileType = .m4v
        let finalURL = NSURL.createNewVideoURL()
        assetExport.outputURL = finalURL
        assetExport.shouldOptimizeForNetworkUse = true

        assetExport.exportAsynchronously() {
            completion(assetExport.status == .completed ? finalURL : nil)
        }
    }

    /// Convenience method to add a track to a composition track at insert time
    ///
    /// - Parameters:
    ///   - assetTrack: track to be added
    ///   - compositionTrack: target composition track
    ///   - time: the insert time of the track
    /// - Returns: success Bool
    @discardableResult class func addTrack(assetTrack: AVAssetTrack, compositionTrack: AVMutableCompositionTrack?, time: CMTime) -> Bool {
        do { try compositionTrack?.insertTimeRange(assetTrack.timeRange, of: assetTrack, at: time) } catch {
            NSLog("failed to insert video track")
            return false
        }
        return true
    }

    /// Creates a video from a UIImage given the settings
    ///
    /// - Parameters:
    ///   - image: UIImage
    ///   - assetWriter: AVAssetWriter
    ///   - adaptor: the pixel buffer adaptor
    ///   - input: asset writer input
    ///   - completion: returns success bool
    func createVideoFromImage(image: UIImage, assetWriter: AVAssetWriter, adaptor: AVAssetWriterInputPixelBufferAdaptor, input: AVAssetWriterInput, completion: @escaping (Bool) -> Void) {
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: kCMTimeZero)
        guard let buffer = pixelBuffer(from: image) else {
            completion(false)
            return
        }
        adaptor.append(buffer: buffer, time: kCMTimeZero, completion: { firstAppended in
            if firstAppended {
                let endTime = KanvasCameraTimes.StopMotionFrameTime
                assetWriter.endSession(atSourceTime: endTime)
                adaptor.assetWriterInput.markAsFinished()
                assetWriter.finishWriting() {
                    completion(assetWriter.status == .completed)
                }
            }
            else {
                assetWriter.cancelWriting()
                completion(false)
            }
        })
    }

    /// Creates a new pixel buffer from a UIImage for appending to an asset writer
    ///
    /// - Parameter image: input UIImage
    /// - Returns: the pixel buffer, if successful
    func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs: CFDictionary = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        guard let ctx = context else { return nil }

        ctx.translateBy(x: 0, y: image.size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        UIGraphicsPushContext(ctx)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(buffer, [])

        return pixelBuffer
    }
}
