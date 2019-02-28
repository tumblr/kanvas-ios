//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Accelerate
import AVFoundation
import Foundation

extension UIImage {
    
    /// Method to write the image data into a pixel buffer
    ///
    /// - Returns: An optional pixel buffer, can be nil if failed to create
    func pixelBuffer() -> CVPixelBuffer? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        let ciImage = CIImage(cgImage: cgImage)
        let width = Int(size.width)
        let height = Int(size.height)
        var initialBuffer: CVPixelBuffer?
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let attributes: NSDictionary = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferIOSurfacePropertiesKey: NSDictionary(),
                          kCVPixelBufferOpenGLESCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferOpenGLCompatibilityKey: kCFBooleanTrue]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &initialBuffer)
        guard status == kCVReturnSuccess, let pixelBuffer = initialBuffer else {
            return nil
        }
        
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, flags) else {
            return nil
        }
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, flags) }
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
                                        NSLog("failed to create pixel buffer context")
                                        return nil
        }
        
        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        return pixelBuffer
    }
}
