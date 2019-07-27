//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import Photos

/// Errors that can be thrown from GLMediaExporter
enum GLMediaExporterError: Error {
    case failedDeleteExistingFile(Error)
    case noPresets
    case noCompositor
    case export(Error)
    case incomplete
    case noPixelBuffer
    case noSampleBuffer
    case noProcessedImage
}

/// Exports media with frame-by-frame OpenGL processing
final class GLMediaExporter {

    /// The FilterType to apply frame-by-frame processing with.
    var filterType: FilterType?

    /// A timer you can hook into to get progress updates from an export.
    private(set) var progressTimer: Timer?

    /// Default initializer
    init(filterType: FilterType?) {
        self.filterType = filterType
    }

    /// Exports an image
    /// - Parameter image: UIImage to export
    /// - Parameter completion: callback which is invoked with the processed UIImage
    func export(image: UIImage, completion: (UIImage?, Error?) -> Void) {
        guard let filterType = filterType else {
            completion(image, nil)
            return
        }
        guard let pixelBuffer = image.pixelBuffer() else {
            completion(nil, GLMediaExporterError.noPixelBuffer)
            return
        }
        guard let sampleBuffer = pixelBuffer.sampleBuffer() else {
            completion(nil, GLMediaExporterError.noSampleBuffer)
            return
        }
        let renderer = GLRenderer()
        renderer.changeFilter(filterType)
        // LOL I have to call this twice, because this was written for video, where the first frame only initializes
        // things and stuff gets rendered for the 2nd frame ¯\_(ツ)_/¯
        renderer.processSampleBuffer(sampleBuffer)
        renderer.processSampleBuffer(sampleBuffer) { (filteredPixelBuffer, time) in
            guard let processedImage = UIImage(pixelBuffer: filteredPixelBuffer) else {
                completion(nil, GLMediaExporterError.noProcessedImage)
                return
            }
            completion(processedImage, nil)
        }
    }

    /// Exports a video
    /// - Parameter video: URL of a video to export
    /// - Parameter completion: callback which is invoked with the processed video URL
    func export(video url: URL, completion: @escaping (URL?, Error?) -> Void) {
        guard let filterType = filterType else {
            completion(url, nil)
            return
        }

        let asset = AVAsset(url: url)
        let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
        videoComposition.customVideoCompositorClass = GLVideoCompositor.self

        // TODO shouldn't I always pick the highest quality, not the first?
        let presets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        guard let presetName = presets.first else {
            completion(nil, GLMediaExporterError.noPresets)
            return
        }

        let outputURL = NSURL.createNewVideoURL()
        let exportSession = AVAssetExportSession(asset: asset, presetName: presetName)
        exportSession?.outputFileType = .mov
        exportSession?.outputURL = outputURL
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.videoComposition = videoComposition
        guard let glVideoCompositor = exportSession?.customVideoCompositor as? GLVideoCompositor else {
            completion(nil, GLMediaExporterError.noCompositor)
            return
        }
        glVideoCompositor.filterType = filterType
        self.progressTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateProgress(_:)), userInfo: exportSession, repeats: true)
        exportSession?.exportAsynchronously {
            self.progressTimer?.invalidate()
            self.progressTimer = nil
            guard exportSession?.status == .completed else {
                if let error = exportSession?.error {
                    completion(nil, GLMediaExporterError.export(error))
                }
                else {
                    completion(nil, GLMediaExporterError.incomplete)
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
