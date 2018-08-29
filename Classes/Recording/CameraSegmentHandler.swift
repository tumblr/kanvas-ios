//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

/// A container for segments
enum CameraSegment {
    // The image can be converted to a video when used in a sequence for stop motion, and thus the url.
    case image(UIImage, URL?)
    case video(URL)
    
    var image: UIImage? {
        switch self {
        case .image(let image, _): return image
        case .video: return nil
        }
    }
    
    var videoURL: URL? {
        switch self {
        case .image(_, let url): return url
        case .video(let url): return url
        }
    }
}

protocol AssetsHandlerType {
    func mergeAssets(segments: [CameraSegment], completion: @escaping (URL?) -> Void)
}

/// A class to handle the various segments of a stop motion video, and also creates the final output

/// A class to handle the various segments of a stop motion video, and also creates the final output

final class CameraSegmentHandler: AssetsHandlerType {
    private(set) var segments: [CameraSegment] = []
    private var assetWriter: AVAssetWriter?
    private var assetWriterVideoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    /// Appends an existing CameraSegment
    ///
    /// - Parameter segment: A camera segment with image or video
    func addSegment(_ segment: CameraSegment) {
        segments.append(segment)
    }
    
    /// Creates a new CameraSegment from a video url and appends to segments
    ///
    /// - Parameter url: the local url of the video
    func addNewVideoSegment(url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            assertionFailure("no video exists at file url")
            return
        }
        let segment = CameraSegment.video(url)
        segments.append(segment)
    }
    
    /// Creates a video from a UIImage representation and appends as a CameraSegment
    ///
    /// - Parameters:
    ///   - image: UIImage
    ///   - size: size (resolution) of the video
    ///   - completion: completion handler, success bool and URL of video
    func addNewImageSegment(image: UIImage, size: CGSize, completion: @escaping (Bool, CameraSegment?) -> Void) {
        guard let url = setupAssetWriter(size: size), let assetWriter = assetWriter, let input = assetWriterVideoInput else {
            completion(false, nil)
            return
        }
        
        let bufferAttributes: [String: Any] = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA, String(kCVPixelBufferCGBitmapContextCompatibilityKey): true, String(kCVPixelBufferCGImageCompatibilityKey): true, String(kCVPixelBufferWidthKey): size.width, String(kCVPixelBufferHeightKey): size.height]
        assetWriter.add(input)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: bufferAttributes)
        createVideoFromImage(image: image, assetWriter: assetWriter, adaptor: adaptor, input: input, completion: { success in
            if success {
                let segment = CameraSegment.image(image, url)
                self.segments.append(segment)
                completion(success, segment)
            }
            else {
                completion(false, nil)
            }
        })
    }
    
    /// Deletes a segment and removes from local storage. When running tests, it should be false
    ///
    /// - Parameters:
    ///   - index: the index of the segment to be deleted
    ///   - removeFromDisk: a bool that determines whether to remove the file from local storage, defaults to true.
    func deleteSegment(index: Int, removeFromDisk: Bool? = true) {
        guard index < segments.count else { return }
        let segment = segments[index]
        let fileManager = FileManager.default
        if removeFromDisk == true, let url = segment.videoURL, fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                NSLog("failed to remove item at \(url)")
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
            else if segment.image != nil {
                totalDuration = CMTimeAdd(totalDuration, KanvasCameraTimes.StopMotionFrameTime)
            }
        }
        return CMTimeGetSeconds(totalDuration)
    }
    
    /// This functions exports the complete final video to a local resource.
    ///
    /// - Parameter completion: returns a local video URL if merged successfully
    func exportVideo(completion: @escaping (URL?) -> Void) {
        mergeAssets(segments: segments, completion: completion)
    }
    
    /// This removes all segments from disk and memory
    func reset(removeFromDisk: Bool? = true) {
        defer { segments.removeAll() }
        guard removeFromDisk == true else {
            return
        }
        let fileManager = FileManager.default
        segments.forEach { (segment) in
            if let url = segment.videoURL, fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(at: url)
                } catch { }
            }
        }
    }
    
    /// concatenates all of the videos in the segments
    ///
    /// - Parameters:
    ///   - segments: the CameraSegments to be merged
    ///   - completion: returns a local video URL if merged successfully
    func mergeAssets(segments: [CameraSegment], completion: @escaping (URL?) -> Void) {
        let mixComposition = AVMutableComposition()
        // the video and audio composition tracks should only be created if there are any video or audio tracks in the segments, otherwise there would be an export issue with an empty composition
        var videoCompTrack, audioCompTrack: AVMutableCompositionTrack?
        var insertTime = kCMTimeZero
        
        for segment in segments {
            guard let segmentURL = segment.videoURL else { continue }
            let urlAsset = AVURLAsset(url: segmentURL)
            var videoDuration: CMTime = kCMTimeZero
            
            if let videoTrack = urlAsset.tracks(withMediaType: .video).first {
                videoCompTrack = videoCompTrack ?? mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
                addTrack(assetTrack: videoTrack, compositionTrack: videoCompTrack, time: insertTime, timeRange: videoTrack.timeRange)
                videoDuration = videoTrack.timeRange.duration
            }
            if let audioTrack = urlAsset.tracks(withMediaType: .audio).first {
                audioCompTrack = audioCompTrack ?? mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
                var audioTimeRange = audioTrack.timeRange
                if CMTimeCompare(audioTrack.timeRange.duration, videoDuration) == 1 {
                    audioTimeRange = CMTimeRangeMake(audioTimeRange.start, videoDuration); // crop audio to video range
                }
                addTrack(assetTrack: audioTrack, compositionTrack: audioCompTrack, time: insertTime, timeRange: audioTimeRange)
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
    static func videoOutputSettingsForSize(size: CGSize) -> [String: Any] {
        return [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: Int(size.width), AVVideoHeightKey: Int(size.height)]
    }
    
    // MARK: - helper functions
    
    /// Sets up the asset writer for video creation
    ///
    /// - Parameter size: resolution of video
    /// - Returns: URL?: the url of the local video
    private func setupAssetWriter(size: CGSize) -> URL? {
        guard let url = NSURL.createNewVideoURL() else {
            return nil
        }
        do {
            assetWriter = try AVAssetWriter(outputURL: url, fileType: AVFileType.mp4)
        } catch {
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
    private func exportComposition(composition: AVMutableComposition, completion: @escaping (URL?) -> Void) {
        guard composition.tracks.count > 0, let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil)
            return
        }
        assetExport.outputFileType = .mp4
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
    private func addTrack(assetTrack: AVAssetTrack, compositionTrack: AVMutableCompositionTrack?, time: CMTime, timeRange: CMTimeRange) {
        do {
            try compositionTrack?.insertTimeRange(timeRange, of: assetTrack, at: time)
        } catch {
            NSLog("No track at range to append.")
        }
    }
    
    /// Creates a video from a UIImage given the settings
    ///
    /// - Parameters:
    ///   - image: UIImage
    ///   - assetWriter: AVAssetWriter
    ///   - adaptor: the pixel buffer adaptor
    ///   - input: asset writer input
    ///   - completion: returns success bool
    private func createVideoFromImage(image: UIImage, assetWriter: AVAssetWriter, adaptor: AVAssetWriterInputPixelBufferAdaptor, input: AVAssetWriterInput, completion: @escaping (Bool) -> Void) {
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: kCMTimeZero)
        guard let buffer = createNewPixelBuffer(from: image) else {
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
    private func createNewPixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs: CFDictionary = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { return nil }
        
        ctx.translateBy(x: 0, y: image.size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        UIGraphicsPushContext(ctx)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return pixelBuffer
    }
}
