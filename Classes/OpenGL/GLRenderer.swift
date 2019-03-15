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
    /// Called when renderer has processed a pixel buffer
    ///
    /// - Parameters:
    ///   - pixelBuffer: the filtered pixel buffer
    ///   - presentationTime: The append time
    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer, presentationTime: CMTime)
    
    /// Called when no buffers are available
    func rendererRanOutOfBuffers()
}

/// Renders pixel buffers with open gl
final class GLRenderer {

    /// Optional delegate
    weak var delegate: GLRendererDelegate?

    // OpenGL Context
    let glContext: EAGLContext?

    private let callbackQueue: DispatchQueue
    private var filter: FilterProtocol
    private var filterType: FilterType = .passthrough
    private var processingImage = false

    /// Designated initializer
    ///
    /// - Parameter delegate: the callback
    init(delegate: GLRendererDelegate?, callbackQueue: DispatchQueue = DispatchQueue.main) {
        self.delegate = delegate
        self.callbackQueue = callbackQueue
        glContext = EAGLContext(api: .openGLES3)
        filter = FilterFactory.createFilter(type: self.filterType, glContext: glContext)
    }
    
    /// Call this method to process the sample buffer
    ///
    /// - Parameter sampleBuffer: the camera feed sample buffer
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        if processingImage {
            return
        }
        if filter.outputFormatDescription == nil {
            filter.setupFormatDescription(from: sampleBuffer)
        }
        else {
            let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

            let filteredPixelBufferMaybe: CVPixelBuffer? = synchronized(filter) {
                let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                return filter.processPixelBuffer(sourcePixelBuffer)
            }

            if let filteredPixelBuffer = filteredPixelBufferMaybe {
                delegate?.rendererReadyForDisplay(pixelBuffer: filteredPixelBuffer, presentationTime: time)
            }
            else {
                delegate?.rendererRanOutOfBuffers()
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
        return filteredPixelBuffer
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
        filter.cleanup()
    }
}
