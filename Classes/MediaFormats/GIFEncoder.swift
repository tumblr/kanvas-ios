//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import CoreServices

import GIFEncoder

class GIFEncoder {

    private struct Constants {
        static let timeInterval: TimeInterval = 600.0
        static let tolerance = 0.01
        static let delayTime = 0.02
    }

    func encodeVideoAsGIF(url: URL, loopCount: Int, framesPerSecond: Int, completion: @escaping (URL?) -> ()) {

        let completionMain = { (url: URL?) in
            DispatchQueue.main.async {
                completion(url)
            }
        }

        DispatchQueue.global(qos: .default).async {

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

            // Get the length of the video in seconds
            let videoLength = Double(asset.duration.value) / Double(asset.duration.timescale)
            let frameCount = Int(videoLength * Double(framesPerSecond))

            // How far along the video track we want to move, in seconds.
            let increment = videoLength / Double(frameCount);

            // Add frames to the buffer
            var timePoints: [CMTime] = [];
            for currentFrame in 0..<frameCount {
                let seconds = increment * Double(currentFrame)
                let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(Constants.timeInterval))
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

            let tol = CMTime(seconds: Constants.tolerance, preferredTimescale: CMTimeScale(Constants.timeInterval))
            generator.requestedTimeToleranceBefore = tol
            generator.requestedTimeToleranceAfter = tol

            for time in timePoints {
                do {
                    let image = try generator.copyCGImage(at: time, actualTime: nil)
                    CGImageDestinationAddImage(destination, image, getFrameProperties(1.0 / Double(framesPerSecond)) as CFDictionary);
                } catch {
                    print("Error copying image: \(error)")
                    completionMain(nil)
                    return
                }
            }

            // Finalize the GIF
            guard CGImageDestinationFinalize(destination) else {
                print("Failed to finalize GIF destination")
                completionMain(nil)
                return
            }

            completionMain(fileURL)
        }
    }
}
