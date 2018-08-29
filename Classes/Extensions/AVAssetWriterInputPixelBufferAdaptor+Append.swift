//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

extension AVAssetWriterInputPixelBufferAdaptor {
    
    /// method to help append a buffer to an asset writer input
    ///
    /// - Parameters:
    ///   - buffer: CVPixelBuffer
    ///   - time: append CMTime
    ///   - completion: Bool for whether the buffer was appended
    func append(buffer: CVPixelBuffer, time: CMTime, completion: @escaping (Bool) -> Void) {
        if assetWriterInput.isReadyForMoreMediaData {
            completion(append(buffer, withPresentationTime: time))
        }
        else {
            let _ = assetWriterInput.observe(\.isReadyForMoreMediaData) { [unowned self] (writer, change) in
                if self.assetWriterInput.isReadyForMoreMediaData {
                    completion(self.append(buffer, withPresentationTime: time))
                }
            }
        }
    }
}
