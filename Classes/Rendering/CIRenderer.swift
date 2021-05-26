//
//  CIRenderer.swift
//  Kanvas
//
//  Created by Brandon Titus on 5/19/21.
//

import Foundation
import GLKit
import CoreMedia
import CoreImage
import CoreImage.CIFilterBuiltins

/// Core Image Renderer
class CIRenderer: Rendering {
    weak var delegate: RendererDelegate?

    var filterPlatform: FilterPlatform

    var filterType: FilterType = .passthrough

    var imageOverlays: [CGImage] = []

    var mediaTransform: GLKMatrix4?

    var switchInputDimensions: Bool

    private let settings: CameraSettings

    private let context = CIContext()

    /// Designated initializer
    ///
    /// - Parameter delegate: the callback
    init(settings: CameraSettings) {
        self.settings = settings
        self.filterPlatform = .metal
//        let filterFactory = FilterFactory(glContext: EAGLContext(api: .openGLES3),
//                                          metalContext: MetalContext.createContext(),
//                                          filterPlatform: filterPlatform)
//        self.filterFactory = filterFactory
        switchInputDimensions = false
    }

    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval) {
        processSampleBuffer(sampleBuffer, time: time, scaleToFillSize: nil) { (_, _) in

        }
    }

    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval, scaleToFillSize: CGSize?) {
        processSampleBuffer(sampleBuffer, time: time, scaleToFillSize: scaleToFillSize) { (_, _) in
        }
    }

    func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer, time: TimeInterval, scaleToFillSize: CGSize?) -> CVPixelBuffer? {
        return try! processImageBuffer(pixelBuffer, scaleToFillSize: scaleToFillSize ?? .zero)
    }


    func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval, scaleToFillSize: CGSize?, completion: (CVPixelBuffer, CMTime) -> Void) {
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let pixelBuffer = try! processImageBuffer(sampleBuffer.imageBuffer!, scaleToFillSize: scaleToFillSize ?? .zero)

        delegate?.rendererFilteredPixelBufferReady(pixelBuffer: pixelBuffer, presentationTime: presentationTime)
        delegate?.rendererReadyForDisplay(pixelBuffer: pixelBuffer)
        completion(pixelBuffer, presentationTime)
    }

    enum CIRendererError: Error {
        case failedPixelBufferCreation
    }

    func processImageBuffer(_ buffer: CVImageBuffer, scaleToFillSize: CGSize = .zero) throws -> CVPixelBuffer {
        let image = CIImage(cvImageBuffer: buffer)

        let scale = CIFilter.lanczosScaleTransform()
        scale.inputImage = image

        let size = image.extent.size.scaledToFill(size: scaleToFillSize ?? .zero)

        scale.scale = Float(image.extent.height / size.height)
//        scale.aspectRatio = Float(size.width / size.height)

        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue, kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue, kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary
        var pixelBuffer : CVPixelBuffer?

        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)

        guard let pixelBuffer = pixelBuffer else {
            throw CIRendererError.failedPixelBufferCreation
        }

        let scaled = scale.outputImage!
        let scaledImage = UIImage(ciImage: scaled)
        let origin = scaled.extent.center.applying(CGAffineTransform(translationX: -(scaleToFillSize ?? .zero).width / 2, y: -scaled.extent.height / 2))
        let output = scaled.cropped(to: CGRect(origin: origin, size: size ?? .zero))
        let testImage = UIImage(ciImage: output)
        delegate?.rendererReadyForDisplay(image: output)
        context.render(output, to: pixelBuffer)
        return pixelBuffer
    }

    func refreshFilter() {

    }

    func reset() {

    }
}
