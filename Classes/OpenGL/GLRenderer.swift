//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import OpenGLES

/// Callbacks for opengl rendering
protocol GLRendererDelegate {
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
    var delegate: GLRendererDelegate?
    private var callbackQueue: DispatchQueue
    
    // opengl
    let glContext: EAGLContext?
    private var filter: FilterProtocol
    private var imageFilter: FilterProtocol
    private var processingImage = false

    /// Designated initializer
    ///
    /// - Parameter delegate: the callback
    init(delegate: GLRendererDelegate?, callbackQueue: DispatchQueue = DispatchQueue.main) {
        self.delegate = delegate
        self.callbackQueue = callbackQueue
        glContext = EAGLContext(api: .openGLES3)
        filter = Filter(glContext: glContext)
        imageFilter = Filter(glContext: glContext)
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
//            let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) // should this be a copy?
            let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)?.copy()
            if let filteredPixelBuffer = filter.processPixelBuffer(sourcePixelBuffer) {
                delegate?.rendererReadyForDisplay(pixelBuffer: filteredPixelBuffer, presentationTime: time)
            }
            else {
                filter.cleanup()
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
        imageFilter.cleanup()
        var sampleTime = CMSampleTimingInfo()
        var videoInfo: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
        
        var buffer: CMSampleBuffer?
        guard let formatDescription = videoInfo else {
            return nil
        }
        let status = CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: formatDescription, sampleTiming: &sampleTime, sampleBufferOut: &buffer)
        guard status == kCVReturnSuccess, let sampleBuffer = buffer else {
            NSLog("error status for creating sample buffer \(status)")
            return nil
        }
        
        if imageFilter.outputFormatDescription == nil {
            imageFilter.setupFormatDescription(from: sampleBuffer)
        }
        let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        return imageFilter.processPixelBuffer(sourcePixelBuffer)
    }

    /// Method to call reset on the camera filter
    func reset() {
        filter.cleanup()
    }
}
