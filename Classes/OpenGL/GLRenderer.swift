//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import OpenGLES

/// Callbacks for opengl rendering
protocol GLRendererDelegate: class {
    /// Called when renderer has a processed pixel buffer ready for display. This may skip frames, so it's only
    /// intended to be used for display purposes.
    ///
    /// - Parameters:
    ///   - pixelBuffer: the filtered pixel buffer
    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer)

    /// Called when renderer has a processed pixel buffer ready. This is called for every frame, so this can be
    /// used for recording purposes.
    ///
    /// - Parameters:
    ///   - pixelBuffer: the filtered pixel buffer
    ///   - presentationTime: The append time
    func rendererFilteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime)
    
    /// Called when no buffers are available
    func rendererRanOutOfBuffers()
}

protocol GLRendering: class {
    var delegate: GLRendererDelegate? { get set }
    var filterType: FilterType { get }
    var imageOverlays: [CGImage] { get set }
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer)
    func output(filteredPixelBuffer: CVPixelBuffer)
    func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer?
    func changeFilter(_ filterType: FilterType)
    func reset()
}

/// Renders pixel buffers with open gl
final class GLRenderer: GLRendering {

    /// Optional delegate
    weak var delegate: GLRendererDelegate?

    // OpenGL Context
    let glContext: EAGLContext?

    // Image overlays
    var imageOverlays: [CGImage] = []

    // Current filter type
    private(set) var filterType: FilterType = .passthrough

    private let callbackQueue: DispatchQueue = DispatchQueue.main
    private var filter: FilterProtocol
    private var processingImage = false
    private var filteredPixelBuffer: CVPixelBuffer?

    /// Designated initializer
    ///
    /// - Parameter delegate: the callback
    init() {
        glContext = EAGLContext(api: .openGLES3)
        filter = FilterFactory.createFilter(type: self.filterType, glContext: glContext)
    }

    /// Processes a sample buffer, but swallows the completion
    ///
    /// - Parameter sampleBuffer: the camera feed sample buffer
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        processSampleBuffer(sampleBuffer) { (_, _) in }
    }
    
    /// Call this method to process the sample buffer
    ///
    /// - Parameter sampleBuffer: the camera feed sample buffer
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, completion: (CVPixelBuffer, CMTime) -> Void) {
        if processingImage {
            return
        }
        let filterAlreadyInitialized: Bool = synchronized(self) {
            if filter.outputFormatDescription == nil {
                filter.setupFormatDescription(from: sampleBuffer)
                return false
            }
            return true
        }
        if filterAlreadyInitialized {
            let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            let filteredPixelBufferMaybe: CVPixelBuffer? = synchronized(self) {
                return filter.processPixelBuffer(sourcePixelBuffer)
            }
            if let filteredPixelBuffer = filteredPixelBufferMaybe {
                synchronized(self) {
                    output(filteredPixelBuffer: filteredPixelBuffer)
                    let finalPixelBuffer = processOverlays(pixelBuffer: filteredPixelBuffer)
                    self.delegate?.rendererFilteredPixelBufferReady(pixelBuffer: finalPixelBuffer, presentationTime: time)
                    completion(finalPixelBuffer, time)
                }
            }
            else {
                callbackQueue.async {
                    self.delegate?.rendererRanOutOfBuffers()
                }
            }
        }
    }

    /// Indicate that the filteredPixelBuffer is ready for display
    ///
    /// This keeps latency low by dropping frames that haven't been processeed by the delegate yet.
    /// For this to work, all access to filteredPixelBuffer should be locked, so this method should be called in
    /// a synchronized(self) block.
    func output(filteredPixelBuffer: CVPixelBuffer) {
        self.filteredPixelBuffer = filteredPixelBuffer
        callbackQueue.async {
            let pixelBuffer: CVPixelBuffer? = synchronized(self) {
                let pixelBuffer = self.filteredPixelBuffer
                if pixelBuffer != nil {
                    self.filteredPixelBuffer = nil
                }
                return pixelBuffer
            }
            if let filteredPixelBuffer = pixelBuffer {
                self.delegate?.rendererReadyForDisplay(pixelBuffer: filteredPixelBuffer)
            }
        }
    }
    
    /// Call this method to process a single pixel buffer
    ///
    /// - Parameter pixelBuffer: the input pixel buffer
    /// - Returns: the filtered pixel buffer
    func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        processingImage = true
        defer {
            processingImage = false
        }

        let imageFilter = FilterFactory.createFilter(type: self.filterType, glContext: glContext)
        var sampleTime = CMSampleTimingInfo()
        var videoInfo: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
        
        var buffer: CMSampleBuffer?
        guard let formatDescription = videoInfo else {
            return nil
        }
        let status = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: formatDescription, sampleTiming: &sampleTime, sampleBufferOut: &buffer)
        guard status == kCVReturnSuccess, let sampleBuffer = buffer else {
            assertionFailure("error status for creating sample buffer \(status)")
            return nil
        }
        
        if imageFilter.outputFormatDescription == nil {
            imageFilter.setupFormatDescription(from: sampleBuffer)
        }
        let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let filteredPixelBuffer = imageFilter.processPixelBuffer(sourcePixelBuffer)
        imageFilter.cleanup()
        let finalPixelBuffer = processOverlays(pixelBuffer: filteredPixelBuffer ?? pixelBuffer)
        return finalPixelBuffer
    }

    private func processOverlays(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        guard imageOverlays.count > 0 else {
            return pixelBuffer
        }
        let size = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let mediaImage = UIImage(pixelBuffer: pixelBuffer)
        mediaImage?.draw(in: areaSize)
        for overlay in imageOverlays {
            let overlayImage = UIImage(cgImage: overlay)
            overlayImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
        }
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        let finalPixelBuffer = finalImage?.pixelBuffer()
        return finalPixelBuffer ?? pixelBuffer
    }

    // MARK: - changing filters
    func changeFilter(_ filterType: FilterType) {
        guard self.filterType != filterType else {
            return
        }

        self.filterType = filterType
        synchronized(self) {
            filter = FilterFactory.createFilter(type: filterType, glContext: glContext)
        }
    }

    /// Method to call reset on the camera filter
    func reset() {
        synchronized(self) {
            filter.cleanup()
        }
    }
}
