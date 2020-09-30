//
//  CVPixelBuffer+resize.swift
//  KanvasCamera
//
//  Created by Taichi Matsumoto on 7/24/20.
//

import AVFoundation
import Foundation

extension CVPixelBuffer {
    func resize(scale: CGFloat) -> CVPixelBuffer? {
        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CILanczosScaleTransform")
        let ciImage = CIImage(cvPixelBuffer: self)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(scale, forKey: kCIInputScaleKey)
        
        guard let resized = filter?.outputImage else {
            return nil
        }
        let attrs: NSDictionary = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue as Any,
                                   kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue as Any,
                                   kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue as Any]
        var outPixelBuffer: CVPixelBuffer?
        let result = CVPixelBufferCreate(kCFAllocatorDefault, Int(resized.extent.size.width), Int(resized.extent.size.height), kCVPixelFormatType_32BGRA, attrs, &outPixelBuffer)
        guard result == kCVReturnSuccess, let unwrappedPixelBuffer = outPixelBuffer else {
            return nil
        }
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        context.render(resized, to: unwrappedPixelBuffer, bounds: resized.extent, colorSpace: rgbColorSpace)
        return outPixelBuffer
    }
}
