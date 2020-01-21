//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import func AVFoundation.AVMakeRect
import Foundation
import OpenGLES
import GLKit

/// Callbacks for rendering
protocol RendererDelegate: class {
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

/// Renders pixel buffers with open gl
final class Renderer: Rendering {

    /// Optional delegate
    weak var delegate: RendererDelegate?

    /// OpenGL Context
    let glContext: EAGLContext?

    /// Image overlays
    var imageOverlays: [CGImage] = []

    /// Transformation matrix that is used by filters to propertly render media
    var mediaTransform: GLKMatrix4? {
        didSet {
            synchronized(self) {
                self.filter.transform = self.mediaTransform
            }
        }
    }

    var switchInputDimensions: Bool {
        didSet {
            synchronized(self) {
                self.filter.switchInputDimensions = self.switchInputDimensions
            }
        }
    }

    /// Current filter type
    var filterType: FilterType = .passthrough

    /// Output dimensions for media
    /// This may be different than the input dimensions, not just because of resolution differences,
    /// but also because the `mediaTransform` may change the dimensions.
    var outputDimensions: CGSize = .zero

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
        switchInputDimensions = false
        mediaTransform = nil
    }

    /// Processes a sample buffer, but swallows the completion
    ///
    /// - Parameter sampleBuffer: the camera feed sample buffer
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval) {
        processSampleBuffer(sampleBuffer, time: time) { (_, _) in }
    }
    
    /// Call this method to process the sample buffer
    ///
    /// - Parameter sampleBuffer: the camera feed sample buffer
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval, completion: (CVPixelBuffer, CMTime) -> Void) {
        if processingImage {
            return
        }
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let filterAlreadyInitialized: Bool = synchronized(self) {
            if filter.outputFormatDescription == nil {
                filter.setupFormatDescription(from: sampleBuffer, outputDimensions: outputDimensions)
                return false
            }
            return true
        }
        if filterAlreadyInitialized {
            let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            let filteredPixelBufferMaybe: CVPixelBuffer? = synchronized(self) {
                return filter.processPixelBuffer(sourcePixelBuffer, time: time)
            }
            if let filteredPixelBuffer = filteredPixelBufferMaybe {
                synchronized(self) {
                    output(filteredPixelBuffer: filteredPixelBuffer)
                    self.delegate?.rendererFilteredPixelBufferReady(pixelBuffer: filteredPixelBuffer, presentationTime: presentationTime)
                    completion(filteredPixelBuffer, presentationTime)
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
    func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer, time: TimeInterval) -> CVPixelBuffer? {
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
            imageFilter.setupFormatDescription(from: sampleBuffer, outputDimensions: outputDimensions)
        }
        let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let filteredPixelBuffer = imageFilter.processPixelBuffer(sourcePixelBuffer, time: time)
        imageFilter.cleanup()
        return filteredPixelBuffer
    }

    // MARK: - changing filters
    func refreshFilter() {
        synchronized(self) {
            filter = FilterFactory.createFilter(type: filterType, glContext: glContext, overlays: imageOverlays.compactMap { UIImage(cgImage: $0).pixelBuffer() })
            filter.transform = mediaTransform
            filter.switchInputDimensions = self.switchInputDimensions
        }
    }

    /// Method to call reset on the camera filter
    func reset() {
        synchronized(self) {
            filter.cleanup()
        }
    }
}
