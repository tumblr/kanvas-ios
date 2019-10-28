//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import GLKit

/// A filter that renders shaders in a chain, with one output leading to the next
class GroupFilter: FilterProtocol {

    /// Output format
    var outputFormatDescription: CMFormatDescription?

    var transform: GLKMatrix4?

    private var filters: [FilterProtocol] = []
    
    init(filters: [FilterProtocol]) {
        self.filters = filters
    }
    
    deinit {
        cleanup()
    }
    
    func setupFormatDescription(from sampleBuffer: CMSampleBuffer) {
        if outputFormatDescription == nil {
            if let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
                outputFormatDescription = formatDescription
            }
            for filter in filters {
                filter.setupFormatDescription(from: sampleBuffer)
            }
        }
    }

    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer?, time: TimeInterval) -> CVPixelBuffer? {
        var inputPixelBuffer: CVPixelBuffer? = pixelBuffer
        for filter in filters {
            if let current = inputPixelBuffer {
                inputPixelBuffer = filter.processPixelBuffer(current, time: time)
            }
        }
        return inputPixelBuffer
    }
    
    func cleanup() {
        if outputFormatDescription != nil {
            outputFormatDescription = nil
        }
    }
}
