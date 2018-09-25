//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

private struct AdaptorConstants {
    static let MaximumAppendAttempts: Int = 50
}

extension AVAssetWriterInputPixelBufferAdaptor {
    
    /// method to help append a buffer to an asset writer input
    ///
    /// - Parameters:
    ///   - buffer: CVPixelBuffer
    ///   - time: append CMTime
    ///   - completion: Bool for whether the buffer was appended
    func append(buffer: CVPixelBuffer, time: CMTime, completion: @escaping (Bool) -> Void) {
        append(buffer: buffer, time: time, attempts: 0, completion: completion)
    }
    
    private func append(buffer: CVPixelBuffer, time: CMTime, attempts: Int, completion: @escaping (Bool) -> Void) {
        if attempts > AdaptorConstants.MaximumAppendAttempts {
            completion(false)
            return
        }
        if assetWriterInput.isReadyForMoreMediaData {
            let appended = append(buffer, withPresentationTime: time)
            completion(appended)
        }
        else {
            performUIUpdateAfter(deadline: .now() + .milliseconds(100), execute: { [unowned self] in
                self.append(buffer: buffer, time: time, attempts: attempts + 1, completion: completion)
            })
        }
    }
}
