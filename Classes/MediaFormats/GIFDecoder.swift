//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

typealias GIFDecodeFrame = (image: CGImage, interval: TimeInterval)

typealias GIFDecodeFrames = (frames: [GIFDecodeFrame], interval: TimeInterval)

class GIFDecoder {

    func decodeWithSDWebImage() {

    }

    func decodeWithImageIO(imageURL: URL, completion: @escaping (GIFDecodeFrames) -> Void) {
        let frames = animatedImage(withAnimatedGIFURL: imageURL)
        completion(frames)
    }

    func delayForImageAtIndex(source: CGImageSource, i: Int) -> Int {
        var delay: Int = 100
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
            if delay == 0 {
                assertionFailure("Delay probably shouldn't be zero")
            }
        }
        return delay
    }

    func createImagesAndDelays(source: CGImageSource, count: Int) -> ([CGImage], [Int]) {
        let images = (0..<count).map{ CGImageSourceCreateImageAtIndex(source, $0, nil)! }
        let delays = (0..<count).map{ delayForImageAtIndex(source: source, i: $0) }
        return (images, delays)
    }

    func sum(_ count: Int, _ values: [Int]) -> Int {
        var theSum = 0;
        for i in 0..<count {
            theSum += values[i]
        }
        return theSum
    }

    func pairGCD(_ a: Int, _ b: Int) -> Int {
        var aa = a;
        var bb = b;
        if (aa < bb) {
            return pairGCD(bb, aa)
        }
        while (true) {
            let r = aa % bb
            if r == 0 {
                return bb
            }
            aa = b
            bb = r
        }
    }

    func vectorGCD(_ count: Int, _ values: [Int]) -> Int {
        var gcd = values[0]
        for i in 1..<count {
            gcd = pairGCD(values[i], gcd);
        }
        return gcd
    }

    func frameArray(_ count: Int, _ images: [CGImage], _ delays: [Int], _ totalDuration: Int) -> [CGImage] {
        let gcd = vectorGCD(count, delays)
        let frameCount = totalDuration / gcd
        var i = 0
        var frames: [CGImage] = []
        while i < count {
            let frame = images[i]
            var j = delays[i] / gcd
            while j > 0 {
                frames.append(frame)
                j -= 1
            }
            i += 1
        }
        return Array(frames[0..<frameCount])
    }

    func animatedImage(withAnimatedGIFImageSource source: CGImageSource) -> GIFDecodeFrames {
        let count = CGImageSourceGetCount(source)
        let (images, delays) = createImagesAndDelays(source: source, count: count)
        let totalDuration = sum(count, delays)
        let frames = frameArray(count, images, delays, totalDuration)
        
        var decodedFrames: [GIFDecodeFrame] = []
        //for i in 0..<images.count {
            //decodedFrames.append((image: images[i], interval: TimeInterval(delays[i])))
        //}
        //return (frames: decodedFrames, interval: 0)
        for i in 0..<frames.count {
            decodedFrames.append((image: frames[i], interval: 0))
        }
        return (frames: decodedFrames, interval: TimeInterval(totalDuration / count))
    }

    func animatedImage(withAnimatedGIFData data: Data) -> GIFDecodeFrames {
        return animatedImage(withAnimatedGIFImageSource: CGImageSourceCreateWithData(data as CFData, nil)!)
    }

    func animatedImage(withAnimatedGIFURL url: URL) -> GIFDecodeFrames {
        return animatedImage(withAnimatedGIFImageSource: CGImageSourceCreateWithURL(url as CFURL, nil)!)
    }

}
