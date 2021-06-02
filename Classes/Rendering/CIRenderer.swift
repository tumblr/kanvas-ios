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

    var viewportTransform: CGAffineTransform = .identity

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
        var buffer : CVPixelBuffer?

        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, attrs, &buffer)

        guard let pixelBuffer = buffer else {
            throw CIRendererError.failedPixelBufferCreation
        }

        let scaled = scale.outputImage!
//        let scaledImage = UIImage(ciImage: scaled)
//        let origin = scaled.extent.center.applying(CGAffineTransform(translationX: -(scaleToFillSize ?? .zero).width / 2, y: -scaled.extent.height / 2))
//        let transformed = scaled.extent.applying()
        let newTransform = viewportTransform//.translatedBy(x: -viewportTransform.tx, y: -viewportTransform.ty) // Zeroing out origin
        let output = scaled.transformed(by: newTransform)
//        let testImage = UIImage(ciImage: output)

        /// Blurred Background
        let filter = CIFilter.gaussianBlur()
        filter.inputImage = scaled.clampedToExtent()//.transformed(by: CGAffineTransform.identity)
        filter.radius = 20
        let blurredImage = filter.outputImage!//.cropped(to: rect).transformed(by: CGAffineTransform(translationX: -image.extent.x, y: -image.extent.y))
        let backgroundImage = blurredImage.cropped(to: scaled.extent)
        //transformed(by: CGAffineTransform(translationX: viewportTransform.tx, y: viewportTransform.ty))
        let compositedImage = output.cropped(to: CGRect(origin: .zero, size: backgroundImage.extent.size)).composited(over: backgroundImage)

        delegate?.rendererReadyForDisplay(image: compositedImage)
        context.render(output, to: pixelBuffer)
        return pixelBuffer
    }

    func refreshFilter() {

    }

    func reset() {

    }
}
