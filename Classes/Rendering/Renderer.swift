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

    /// Metal Context
    let metalContext: MetalContext?

    /// Image overlays
    var imageOverlays: [CGImage] = []

    /// Current filter type
    var filterType: FilterType = .passthrough

    /// Transformation matrix that is used by filters to propertly render media
    var mediaTransform: GLKMatrix4?

    /// Indicates we should fip the dimensions of input media
    var switchInputDimensions: Bool {
        didSet {
            synchronized(self) {
                self.filter.switchInputDimensions = self.switchInputDimensions
            }
        }
    }

    private let settings: CameraSettings?
    private let callbackQueue: DispatchQueue = DispatchQueue.main
    private var filter: FilterProtocol
    private let filterFactory: FilterFactory
    private var processingImage = false
    private var filteredPixelBuffer: CVPixelBuffer?

    /// Designated initializer
    ///
    /// - Parameter delegate: the callback
    init(settings: CameraSettings?=nil, metalContext: MetalContext?=nil) {
        glContext = EAGLContext(api: .openGLES3)
        self.settings = settings
        self.metalContext = metalContext
        let filterFactory = FilterFactory(glContext: glContext,
                                          metalContext: metalContext,
                                          filterPlatform: settings?.features.metalFilters == true ? .metal : .openGL)
        filter = filterFactory.createFilter(type: self.filterType)
        self.filterFactory = filterFactory
        switchInputDimensions = false
    }

    /// Processes a sample buffer, but swallows the completion
    ///
    /// - Parameter sampleBuffer: the sample buffer to process
    /// - Parameter time: the timestamp associated with the sample buffer
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval) {
        processSampleBuffer(sampleBuffer, time: time, scaleToFillSize: nil)
    }

    /// Processes a sample buffer, but swallows the completion
    ///
    /// - Parameter sampleBuffer: the sample buffer to process
    /// - Parameter time: the timestamp associated with the sample buffer
    /// - Parameter scaleToFillSize: the size the sample buffer is intended to be rendered inside of
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval, scaleToFillSize: CGSize?) {
        processSampleBuffer(sampleBuffer, time: time, scaleToFillSize: scaleToFillSize) { (_, _) in }
    }

    /// Processes a sample buffer
    ///
    /// - Parameter sampleBuffer: the sample buffer to process
    /// - Parameter time: the timestamp associated with the sample buffer
    /// - Parameter completion: called when the sample buffer is processed
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval, completion: (CVPixelBuffer, CMTime) -> Void) {
        processSampleBuffer(sampleBuffer, time: time, scaleToFillSize: nil, completion: completion)
    }
    
    /// Call this method to process the sample buffer
    ///
    /// - Parameter sampleBuffer: the camera feed sample buffer
    /// - Parameter time: the presentation time for the sample buffer
    /// - Parameter scaleToFillSize: the size the sample buffer is intended to be rendered inside of
    /// - Parameter completion: called when the sample buffer is processed
    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval, scaleToFillSize: CGSize?, completion: (CVPixelBuffer, CMTime) -> Void) {
        if processingImage {
            return
        }
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let filterAlreadyInitialized: Bool = synchronized(self) {
            if filter.outputFormatDescription == nil {
                let (finalMediaTransform, outputDimensions) = configureScaleToFill(sampleBuffer: sampleBuffer, size: scaleToFillSize)
                filter.setupFormatDescription(from: sampleBuffer, transform: finalMediaTransform, outputDimensions: outputDimensions ?? .zero)
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
    private func output(filteredPixelBuffer: CVPixelBuffer) {
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
    func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer, time: TimeInterval, scaleToFillSize: CGSize?) -> CVPixelBuffer? {
        processingImage = true
        defer {
            processingImage = false
        }

        let imageFilter = filterFactory.createFilter(type: self.filterType)
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
            let (finalMediaTransform, outputDimensions) = configureScaleToFill(sampleBuffer: sampleBuffer, size: scaleToFillSize)
            imageFilter.setupFormatDescription(from: sampleBuffer, transform: finalMediaTransform, outputDimensions: outputDimensions ?? .zero)
        }
        let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let filteredPixelBuffer = imageFilter.processPixelBuffer(sourcePixelBuffer, time: time)
        imageFilter.cleanup()
        return filteredPixelBuffer
    }

    /// Configures the renderer to scale the input media to fill inside the provided outputDimensions
    private func configureScaleToFill(sampleBuffer: CMSampleBuffer, size: CGSize?) -> (GLKMatrix4?, CGSize?) {
        // If size is provided, setup the renderer to crop this sample buffer to size's aspect ratio.
        if let scaleToFillSize = size, let inputFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let dimensions = CMVideoFormatDescriptionGetDimensions(inputFormatDescription)
            let inputDimensions = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
            let outputDimensions = CGSize(width: inputDimensions.height * (scaleToFillSize.width / scaleToFillSize.height), height: inputDimensions.height)
            let finalMediaTransform = GLKMatrix4Multiply(scaleWithMatrix(inputDimensions: inputDimensions, outputDimensions: outputDimensions), mediaTransform ?? GLKMatrix4Identity)
            return (finalMediaTransform, outputDimensions)
        }
        return (mediaTransform ?? GLKMatrix4Identity, nil)
    }

    // MARK: - changing filters

    /// Refreshes a filter (used when changing the filter type)
    func refreshFilter() {
        synchronized(self) {
            filter = filterFactory.createFilter(type: filterType, overlays: imageOverlays.compactMap { UIImage(cgImage: $0).pixelBuffer() })
            filter.switchInputDimensions = self.switchInputDimensions
        }
    }

    /// Method to call reset on the camera filter
    func reset() {
        synchronized(self) {
            filter.switchInputDimensions = self.switchInputDimensions
            filter.cleanup()
        }
    }
}
