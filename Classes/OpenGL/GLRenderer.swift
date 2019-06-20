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

/// Renders pixel buffers with open gl
final class GLRenderer {

    /// Optional delegate
    weak var delegate: GLRendererDelegate?

    // OpenGL Context
    let glContext: EAGLContext?

    private let callbackQueue: DispatchQueue = DispatchQueue.main
    private var filter: FilterProtocol
    private(set) var filterType: FilterType = .passthrough
    private var processingImage = false

    private var filteredPixelBuffer: CVPixelBuffer?

    /// Designated initializer
    ///
    /// - Parameter delegate: the callback
    init() {
        glContext = EAGLContext(api: .openGLES3)
        filter = FilterFactory.createFilter(type: self.filterType, glContext: glContext)
    }

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
                    self.delegate?.rendererFilteredPixelBufferReady(pixelBuffer: filteredPixelBuffer, presentationTime: time)
                    completion(filteredPixelBuffer, time)
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
        synchronized(self) {
            filter.cleanup()
        }
    }
}
