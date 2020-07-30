//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation

extension CVPixelBuffer {

    /// Create a CMSampleBuffer from this image buffer.
    /// - returns: CMSampleBuffer?
    func sampleBuffer() -> CMSampleBuffer? {
        var sampleBufferMaybe: CMSampleBuffer?
        var formatDescriptionMaybe: CMFormatDescription?
        var timingInfo = CMSampleTimingInfo(duration: CMTime(value: 0, timescale: 1), presentationTimeStamp: CMTime(value: 0, timescale: 1), decodeTimeStamp: CMTime(value: 0, timescale: 1))
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: self, formatDescriptionOut: &formatDescriptionMaybe)
        guard let formatDescription = formatDescriptionMaybe else {
            return nil
        }
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                           imageBuffer: self,
                                           dataReady: true,
                                           makeDataReadyCallback: nil,
                                           refcon: nil,
                                           formatDescription: formatDescription,
                                           sampleTiming: &timingInfo,
                                           sampleBufferOut: &sampleBufferMaybe)
        return sampleBufferMaybe
    }

}
