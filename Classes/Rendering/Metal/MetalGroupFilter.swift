//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import GLKit

class MetalGroupFilter: FilterProtocol {
    var outputFormatDescription: CMFormatDescription?
    var transform: GLKMatrix4?
    var switchInputDimensions: Bool = false
    
    private let filters: [MetalFilter]
    
    init(filters: [MetalFilter]) {
        self.filters = filters
    }
    
    func setupFormatDescription(from sampleBuffer: CMSampleBuffer, transform: GLKMatrix4?, outputDimensions: CGSize) {
        for filter in filters {
            filter.setupFormatDescription(from: sampleBuffer, transform: transform, outputDimensions: outputDimensions)
        }
        outputFormatDescription = filters.last?.outputFormatDescription
    }
    
    func setupFormatDescription(inputDimensions: CGSize, transform: GLKMatrix4?, outputDimensions: CGSize) {
        for filter in filters {
            filter.setupFormatDescription(inputDimensions: inputDimensions, transform: transform, outputDimensions: outputDimensions)
        }
        outputFormatDescription = filters.last?.outputFormatDescription
    }
    
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer?, time: TimeInterval) -> CVPixelBuffer? {
        var currentResult = pixelBuffer
        for filter in filters {
            currentResult = filter.processPixelBuffer(currentResult, time: time)
        }
        return currentResult
    }
    
    func cleanup() {
        for filter in filters {
            filter.cleanup()
        }
    }
}
