//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import Photos

/// Errors that can be thrown from MediaExporter
enum MediaExporterError: Error {
    case failedDeleteExistingFile(Error)
    case noPresets
    case noVideoTrack
    case noCompositor
    case export(Error)
    case incomplete
    case noPixelBuffer
    case noSampleBuffer
    case noProcessedImage
}

protocol MediaExporting: class {
    var filterType: FilterType { get set }
    var imageOverlays: [CGImage] { get set }
    init(settings: CameraSettings)
    func export(image: UIImage, time: TimeInterval, completion: @escaping (UIImage?, Error?) -> Void)
    func export(frames: [MediaFrame], completion: @escaping ([MediaFrame]) -> Void)
    func export(video url: URL, mediaInfo: MediaInfo, completion: @escaping (URL?, Error?) -> Void)
}


/// Exports media with frame-by-frame OpenGL processing
final class MediaExporter: MediaExporting {

    /// The FilterType to apply frame-by-frame processing with.
    var filterType: FilterType = .passthrough

    /// The image overlays to apply on top of each frame.
    var imageOverlays: [CGImage] = []

    var dimensions: CGSize = .zero

    /// A timer you can hook into to get progress updates from an export.
    private(set) var progressTimer: Timer?

    /// Whether or not the exporter needs to process a photo or video
    /// ie. are there any filters or overlays to apply?
    private var needsProcessing: Bool {
        // TODO it'd be nice to optimize this to not do anything if there's no overlay or filters,
        // but right now there's *always* an overlay (a fully transparent image if there's not drawing),
        // so there needs to be some refactoring to make this work well.
        return true
    }
    
    private let settings: CameraSettings
    
    init(settings: CameraSettings) {
        self.settings = settings
    }

    /// Exports an image
    /// - Parameter image: UIImage to export
    /// - Parameter completion: callback which is invoked with the processed UIImage
    func export(image: UIImage, time: TimeInterval, completion: @escaping (UIImage?, Error?) -> Void) {
        guard needsProcessing else {
            completion(image, nil)
            return
        }
        guard let pixelBuffer = image.pixelBuffer() else {
            completion(nil, MediaExporterError.noPixelBuffer)
            return
        }
        guard let sampleBuffer = pixelBuffer.sampleBuffer() else {
            completion(nil, MediaExporterError.noSampleBuffer)
            return
        }
        let renderer = Renderer(settings: settings, metalContext: MetalContext.createContext())
        renderer.imageOverlays = imageOverlays
        renderer.filterType = filterType
        renderer.refreshFilter()
        // LOL I have to call this twice, because this was written for video, where the first frame only initializes
        // things and stuff gets rendered for the 2nd frame ¯\_(ツ)_/¯
        renderer.processSampleBuffer(sampleBuffer, time: time)
        renderer.processSampleBuffer(sampleBuffer, time: time) { (filteredPixelBuffer, time) in
            guard let processedImage = UIImage(pixelBuffer: filteredPixelBuffer) else {
                completion(nil, MediaExporterError.noProcessedImage)
                return
            }
            completion(processedImage, nil)
        }
    }

    func export(frames: [MediaFrame], completion: @escaping ([MediaFrame]) -> Void) {
        var processedFrames: [MediaFrame] = []
        DispatchQueue.global(qos: .default).async {
            var time: TimeInterval = 0
            for frame in frames {
                self.export(image: frame.image, time: time) { (image, error) in
                    guard error == nil, let image = image else {
                        return
                    }
                    time += frame.interval
                    processedFrames.append((image: image, interval: frame.interval))
                }
            }
            DispatchQueue.main.async {
                completion(processedFrames)
            }
        }
    }

    /// Exports a video
    /// - Parameter video: URL of a video to export
    /// - Parameter completion: callback which is invoked with the processed video URL
    func export(video url: URL, mediaInfo: MediaInfo, completion: @escaping (URL?, Error?) -> Void) {
        guard needsProcessing else {
            completion(url, nil)
            return
        }

        let asset = AVAsset(url: url)
        let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
        videoComposition.customVideoCompositorClass = VideoCompositor.self

        let presets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        guard let presetName = presets.first(where: { $0 == AVAssetExportPresetHighestQuality }) else {
            completion(nil, MediaExporterError.noPresets)
            return
        }
        guard let track = asset.tracks(withMediaType: .video).first else {
            completion(nil, MediaExporterError.noVideoTrack)
            return
        }

        let outputURL = try? URL.videoURL()
        let exportSession = AVAssetExportSession(asset: asset, presetName: presetName)
        exportSession?.outputFileType = .mov
        exportSession?.outputURL = outputURL
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.metadata = mediaInfo.createAVMetadataItems()
        exportSession?.videoComposition = videoComposition

        guard let videoCompositor = exportSession?.customVideoCompositor as? VideoCompositor else {
            completion(nil, MediaExporterError.noCompositor)
            return
        }
        videoCompositor.renderer.switchInputDimensions = track.orientation.isPortrait
        videoCompositor.renderer.mediaTransform = track.glPreferredTransform
        videoCompositor.imageOverlays = imageOverlays
        videoCompositor.filterType = filterType
        videoCompositor.refreshFilter()
        self.progressTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateProgress(_:)), userInfo: exportSession, repeats: true)
        exportSession?.exportAsynchronously {
            self.progressTimer?.invalidate()
            self.progressTimer = nil
            guard exportSession?.status == .completed else {
                if let error = exportSession?.error {
                    completion(nil, MediaExporterError.export(error))
                }
                else {
                    completion(nil, MediaExporterError.incomplete)
                }
                return
            }
            completion(outputURL, nil)
        }
    }

    @objc private func updateProgress(_ timer: Timer) {
        guard let exportSession = timer.userInfo as? AVAssetExportSession else {
            return
        }
        print(exportSession.progress)
    }
}
