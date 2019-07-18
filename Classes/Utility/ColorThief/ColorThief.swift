//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

final class ColorThief {
    
    public static let defaultQuality = 10
    public static let defaultIgnoreWhite = true
    
    /// Use the median cut algorithm to cluster similar colors and return the
    /// base color from the largest cluster.
    ///
    /// - Parameters:
    ///   - image: the source image
    ///   - quality: 1 is the highest quality settings. 10 is the default. There is
    ///              a trade-off between quality and speed. The bigger the number,
    ///              the faster a color will be returned but the greater the
    ///              likelihood that it will not be the visually most dominant
    ///              color.
    ///   - ignoreWhite: if true, white pixels are ignored
    /// - Returns: the dominant color
    public static func getColor(from image: UIImage, quality: Int = defaultQuality, ignoreWhite: Bool = defaultIgnoreWhite) -> MMCQ.Color? {
        guard let palette = getPalette(from: image, colorCount: 5, quality: quality, ignoreWhite: ignoreWhite) else {
            return nil
        }
        let dominantColor = palette[0]
        return dominantColor
    }
    
    /// Use the median cut algorithm to cluster similar colors.
    ///
    /// - Parameters:
    ///   - image: the source image
    ///   - colorCount: the size of the palette; the number of colors returned.
    ///                 *the actual size of array becomes smaller than this.
    ///                 this is intended to align with the original Java version.*
    ///   - quality: 1 is the highest quality settings. 10 is the default. There is
    ///              a trade-off between quality and speed. The bigger the number,
    ///              the faster the palette generation but the greater the
    ///              likelihood that colors will be missed.
    ///   - ignoreWhite: if true, white pixels are ignored
    /// - Returns: the palette
    public static func getPalette(from image: UIImage, colorCount: Int, quality: Int = defaultQuality, ignoreWhite: Bool = defaultIgnoreWhite) -> [MMCQ.Color]? {
        guard let colorMap = getColorMap(from: image, colorCount: colorCount, quality: quality, ignoreWhite: ignoreWhite) else {
            return nil
        }
        return colorMap.makePalette()
    }
    
    /// Use the median cut algorithm to cluster similar colors.
    ///
    /// - Parameters:
    ///   - image: the source image
    ///   - colorCount: the size of the palette; the number of colors returned.
    ///                 *the actual size of array becomes smaller than this.
    ///                 this is intended to align with the original Java version.*
    ///   - quality: 1 is the highest quality settings. 10 is the default. There is
    ///              a trade-off between quality and speed. The bigger the number,
    ///              the faster the palette generation but the greater the
    ///              likelihood that colors will be missed.
    ///   - ignoreWhite: if true, white pixels are ignored
    /// - Returns: the color map
    public static func getColorMap(from image: UIImage, colorCount: Int, quality: Int = defaultQuality, ignoreWhite: Bool = defaultIgnoreWhite) -> MMCQ.ColorMap? {
        guard let pixels = makeBytes(from: image) else {
            return nil
        }
        let colorMap = MMCQ.quantize(pixels, quality: quality, ignoreWhite: ignoreWhite, maxColors: colorCount)
        return colorMap
    }
    
    static func makeBytes(from image: UIImage) -> [UInt8]? {
        guard let cgImage = image.cgImage else {
            return nil
        }
        if isCompatibleImage(cgImage) {
            return makeBytesFromCompatibleImage(cgImage)
        }
        else {
            return makeBytesFromIncompatibleImage(cgImage)
        }
    }
    
    static func isCompatibleImage(_ cgImage: CGImage) -> Bool {
        guard let colorSpace = cgImage.colorSpace else {
            return false
        }
        if colorSpace.model != .rgb {
            return false
        }
        let bitmapInfo = cgImage.bitmapInfo
        let alpha = bitmapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        let alphaRequirement = (alpha == CGImageAlphaInfo.noneSkipLast.rawValue || alpha == CGImageAlphaInfo.last.rawValue)
        let byteOrder = bitmapInfo.rawValue & CGBitmapInfo.byteOrderMask.rawValue
        let byteOrderRequirement = (byteOrder == CGBitmapInfo.byteOrder32Little.rawValue)
        if !(alphaRequirement && byteOrderRequirement) {
            return false
        }
        if cgImage.bitsPerComponent != 8 {
            return false
        }
        if cgImage.bitsPerPixel != 32 {
            return false
        }
        if cgImage.bytesPerRow != cgImage.width * 4 {
            return false
        }
        return true
    }
    
    static func makeBytesFromCompatibleImage(_ image: CGImage) -> [UInt8]? {
        guard let dataProvider = image.dataProvider else {
            return nil
        }
        guard let data = dataProvider.data else {
            return nil
        }
        let length = CFDataGetLength(data)
        var rawData = [UInt8](repeating: 0, count: length)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        return rawData
    }
    
    static func makeBytesFromIncompatibleImage(_ image: CGImage) -> [UInt8]? {
        let width = image.width
        let height = image.height
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else {
                return nil
        }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return rawData
    }
    
}
