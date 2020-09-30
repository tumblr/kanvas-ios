//
//  CVPixelBuffer+copy.swift
//  KanvasCamera
//
//  Created by Tony Cheng on 12/19/18.
//

import AVFoundation
import Foundation

extension CVPixelBuffer {
    /// Deep copy a CVPixelBuffer:
    func copy() -> CVPixelBuffer? {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let format = CVPixelBufferGetPixelFormatType(self)
        
        var pixelBuffer: CVPixelBuffer?
        let attributes: NSDictionary = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue as Any,
                                        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue as Any,
                                        kCVPixelBufferIOSurfacePropertiesKey: NSDictionary(),
                                        kCVPixelBufferOpenGLESCompatibilityKey: kCFBooleanTrue as Any,
                                        kCVPixelBufferOpenGLCompatibilityKey: kCFBooleanTrue as Any,
                                        kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue as Any]

        CVPixelBufferCreate(nil, width, height, format, attributes, &pixelBuffer)
        
        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(self, .readOnly)
            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            let baseAddress = CVPixelBufferGetBaseAddress(self)
            let dataSize = CVPixelBufferGetDataSize(self)
            let target = CVPixelBufferGetBaseAddress(pixelBuffer)
            memcpy(target, baseAddress, dataSize)
            CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            CVPixelBufferUnlockBaseAddress(self, .readOnly)
        }
        return pixelBuffer
    }
}
