//
// Created by Tony Cheng on 8/14/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

import AVFoundation
import Foundation

extension AVURLAsset {

    //// returns a UIImage at a video URL, if available
    func thumbnail() -> UIImage? {
        let imgGenerator = AVAssetImageGenerator(asset: self)
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        } catch {
            assertionFailure("failed to get thumbnail")
        }

        return nil
    }
}
