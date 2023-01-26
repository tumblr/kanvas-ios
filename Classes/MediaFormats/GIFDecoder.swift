//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreGraphics
import ImageIO

typealias GIFDecodeFrame = (image: CGImage, interval: TimeInterval)

typealias GIFDecodeFrames = [GIFDecodeFrame]

typealias GIFDecodeFramesUniformDelay = (frames: [CGImage], interval: TimeInterval)

enum GIFDecoderType {
    case imageIO
}

protocol GIFDecoder {
    func decode(image url: URL, completion: @escaping (GIFDecodeFrames) -> Void)
    func numberOfFrames(in url: URL) -> Int
    func numberOfFrames(in data: Data) -> Int
    func size(of url: URL) -> CGSize
}

class GIFDecoderFactory {
    static func create(type: GIFDecoderType) -> GIFDecoder {
        switch type {
        case .imageIO:
            return GIFDecoderImageIO()
        }
    }

    static func main() -> GIFDecoder {
        return create(type: .imageIO)
    }
}

class GIFDecoderImageIO: GIFDecoder {

    fileprivate init() {

    }

    func decode(image url: URL, completion: @escaping (GIFDecodeFrames) -> Void) {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            completion([])
            return
        }
        let frames: GIFDecodeFrames = getFrames(from: source)
        completion(frames)
    }

    func numberOfFrames(in data: Data) -> Int {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return 0
        }
        return CGImageSourceGetCount(source)
    }

    func numberOfFrames(in url: URL) -> Int {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return 0
        }
        return CGImageSourceGetCount(source)
    }

    func size(of url: URL) -> CGSize {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return .zero
        }
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) else {
            return .zero
        }
        guard let width = (properties as NSDictionary)[kCGImagePropertyPixelWidth] as? Int,
            let height = (properties as NSDictionary)[kCGImagePropertyPixelHeight] as? Int
            else {
                return .zero
        }
        return .init(width: width, height: height)
    }

    private func getFrames(from source: CGImageSource) -> GIFDecodeFramesUniformDelay {
        let (images, delays) = getImagesAndDelays(for: source)
        guard images.count > 1 else {
            return (frames: [], interval: 0)
        }
        let (frames, uniformDelay) = getFramesWithConstantDelay(images: images, delays: delays)
        return (frames: frames, interval: TimeInterval(Double(uniformDelay) / 1000.0))
    }

    private func getFrames(from source: CGImageSource) -> GIFDecodeFrames {
        let (images, delays) = getImagesAndDelays(for: source)
        guard images.count > 1 else {
            return []
        }
        let frames = (0..<images.count).map{ (image: images[$0], interval: TimeInterval(Double(delays[$0]) / 1000.0)) }
        return frames
    }

    private func getImagesAndDelays(for source: CGImageSource) -> ([CGImage], [Int]) {
        let count = CGImageSourceGetCount(source)
        let images = (0..<count).compactMap { CGImageSourceCreateImageAtIndex(source, $0, nil) }
        guard images.count == count else {
            assertionFailure("Failed to get a frame from an animated image")
            return ([], [])
        }
        let delays = (0..<count).map { delay(for: source, at: $0) }
        return (images, delays)
    }

    private func delay(for source: CGImageSource, at i: Int) -> Int {
        var delay = 100
        guard let properties: CFDictionary = CGImageSourceCopyPropertiesAtIndex(source, i, nil) else {
            return delay
        }
        guard let gifProperties: NSDictionary = (properties as NSDictionary)[kCGImagePropertyGIFDictionary] as? NSDictionary else {
            return delay
        }
        var number = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber
        if number == nil || number == 0 {
            number = gifProperties[kCGImagePropertyGIFDelayTime] as? NSNumber
        }
        if let number = number {
            delay = Int(number.doubleValue * 1000)
        }
        return delay
    }

    private func getFramesWithConstantDelay(images: [CGImage], delays: [Int]) -> ([CGImage], Int) {
        guard images.count == delays.count else {
            assertionFailure("images and delays must be the same size")
            return ([], 0)
        }
        let totalDuration = sum(delays)
        let gcd = vectorGCD(delays)
        let frameCount = totalDuration / gcd
        var i = 0
        var frames: [CGImage] = []
        while i < delays.count {
            let frame = images[i]
            var j = delays[i] / gcd
            while j > 0 {
                frames.append(frame)
                j -= 1
            }
            i += 1
        }
        return (Array(frames[0..<frameCount]), totalDuration / delays.count)
    }

}
