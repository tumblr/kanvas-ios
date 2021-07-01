//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

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
