//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import CoreServices
import CoreGraphics
import UIKit

protocol GIFEncoder {
    init()
    func encode(video url: URL, loopCount: Int, framesPerSecond: Int, completion: @escaping (URL?) -> Void)
    func encode(frames: [(image: UIImage, interval: TimeInterval)], loopCount: Int, completion: @escaping (URL?) -> Void)
}

enum GIFSize {
    case veryLow, low, medium, high, original

    static let defaultSize = GIFSize.medium

    init(size: CGSize) {
        if size.width >= 1200 || size.height >= 1200 {
            self = .veryLow
        }
        else if size.width >= 800 || size.height >= 800 {
            self = .low
        }
        else if size.width >= 400 || size.height >= 400 {
            self = .medium
        }
        else if size.width > 0 || size.height > 0 {
            self = .high
        }
        else {
            self = .original
        }
    }

    private var scaleFactor: CGFloat {
        switch self {
        case .veryLow:
            return 2/10.0
        case .low:
            return 3/10.0
        case .medium:
            return 5/10.0
        case .high:
            return 7/10.0
        case .original:
            return 1.0
        }
    }

    func scale(image: CGImage) -> CGImage? {
        guard scaleFactor != 1.0 else {
            return image
        }
        let newSize = CGSize(width: CGFloat(image.width) * (scaleFactor / UIScreen.main.scale), height: CGFloat(image.height) * (scaleFactor / UIScreen.main.scale))
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }

        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = .high
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        context?.concatenate(flipVertical)
        context?.draw(image, in: newRect)
        return context?.makeImage()
    }
}

final class GIFEncoderImageIO: GIFEncoder {

    private struct Constants {
        static let timeScale: CMTimeScale = CMTimeScale(600)
    }
    
    private var encodeFramesTask: Task<Void, Error>?
    private var encodeVideoTask: Task<Void, Error>?

    init() {

    }
    
    deinit {
        encodeFramesTask?.cancel()
        encodeVideoTask?.cancel()
    }

    func encode(frames: [(image: UIImage, interval: TimeInterval)], loopCount: Int, completion: @escaping (URL?) -> Void) {

        guard frames.count > 0 else {
            assertionFailure("At least one frame is needed to encode a GIF")
            completion(nil)
            return
        }

        let completionMain = { (url: URL?) in
            DispatchQueue.main.async {
                completion(url)
            }
        }
        
        encodeFramesTask = Task.detached(priority: .medium) {
            
            let getFileProperties = { (loopCount: Int) in
                return [
                    kCGImagePropertyGIFDictionary: [
                        kCGImagePropertyGIFLoopCount: loopCount
                    ]
                ]
            }
            
            let getFrameProperties = { (delayTime: TimeInterval) in
                return [
                    kCGImagePropertyGIFDictionary: [
                        kCGImagePropertyGIFDelayTime: delayTime,
                        kCGImagePropertyColorModel: kCGImagePropertyColorModelRGB,
                    ]
                ]
            }
            
            let timeEncodedFileName = String(format: "%@-%lu.gif", "kanvas-gif", Date().timeIntervalSince1970)
            let temporaryFile = NSTemporaryDirectory().appending(timeEncodedFileName)
            let fileURL = URL(fileURLWithPath: temporaryFile)
            
            guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, frames.count, nil) else {
                completionMain(nil)
                return
            }
            CGImageDestinationSetProperties(destination, getFileProperties(loopCount) as CFDictionary)
            
            for frame in frames {
                autoreleasepool {
                    if let image = frame.image.cgImage {
                        CGImageDestinationAddImage(destination, image, getFrameProperties(frame.interval) as CFDictionary)
                    }
                    else {
                        assertionFailure("GIF frame missing")
                        completionMain(nil)
                        return
                    }
                }
            }
            
            guard CGImageDestinationFinalize(destination) else {
                assertionFailure("Failed to finalize GIF destination")
                completionMain(nil)
                return
            }
            
            completionMain(fileURL)
        }
    }

    func encode(video url: URL, loopCount: Int, framesPerSecond: Int, completion: @escaping (URL?) -> Void) {

        let completionMain = { (url: URL?) in
            DispatchQueue.main.async {
                completion(url)
            }
        }
        
        encodeVideoTask = Task.detached(priority: .medium) {
            
            let getFileProperties = { (loopCount: Int) in
                return [
                    kCGImagePropertyGIFDictionary: [
                        kCGImagePropertyGIFLoopCount: loopCount
                    ]
                ]
            }
            
            let getFrameProperties = { (delayTime: TimeInterval) in
                return [
                    kCGImagePropertyGIFDictionary: [
                        kCGImagePropertyGIFDelayTime: delayTime,
                        kCGImagePropertyColorModel: kCGImagePropertyColorModelRGB,
                    ]
                ]
            }
            
            let asset = AVAsset(url: url)
            let gifSize = GIFSize(size: asset.videoScreenSize ?? .zero)
            
            let videoLength = Double(asset.duration.value) / Double(asset.duration.timescale)
            let frameCount = Int(videoLength * Double(framesPerSecond))
            let increment = videoLength / Double(frameCount)
            
            var timePoints: [CMTime] = []
            for currentFrame in 0..<frameCount {
                let seconds = increment * Double(currentFrame)
                let time = CMTime(seconds: seconds, preferredTimescale: Constants.timeScale)
                timePoints.append(time)
            }
            
            let timeEncodedFileName = String(format: "%@-%lu.gif", "kanvas-gif", Date().timeIntervalSince1970)
            let temporaryFile = NSTemporaryDirectory().appending(timeEncodedFileName)
            let fileURL = URL(fileURLWithPath: temporaryFile)
            
            guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, frameCount, nil) else {
                completionMain(nil)
                return
            }
            CGImageDestinationSetProperties(destination, getFileProperties(loopCount) as CFDictionary)
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero
            
            // AVAssetImageGenerator.generateCGImagesAsynchronously would be a more
            // efficient alternative to looping through all the times and calling
            // AVAssetImageGenerator.copyCGImage.
            for time in timePoints {
                do {
                    var image = try generator.copyCGImage(at: time, actualTime: nil)
                    image = gifSize.scale(image: image) ?? image
                    CGImageDestinationAddImage(destination, image, getFrameProperties(1.0 / Double(framesPerSecond)) as CFDictionary)
                } catch {
                    assertionFailure("Error copying GIF frame: \(error)")
                    completionMain(nil)
                    return
                }
            }
            
            guard CGImageDestinationFinalize(destination) else {
                completionMain(nil)
                return
            }
            
            completionMain(fileURL)
        }
    }

}
