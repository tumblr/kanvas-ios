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

    var switchInputDimensions: Bool {
        get {
            return filters.first?.switchInputDimensions ?? false
        }
        set {
            filters.first?.switchInputDimensions = newValue
        }
    }

    /// Output format
    var outputFormatDescription: CMFormatDescription? {
        get {
            return filters.first?.outputFormatDescription
        }
        set {
            filters.first?.outputFormatDescription = newValue
        }
    }

    var transform: GLKMatrix4? {
        get {
            return filters.first?.transform
        }
        set {
            filters.first?.transform = newValue
        }
    }

    private var filters: [FilterProtocol] = []
    
    init(filters: [FilterProtocol]) {
        self.filters = filters
    }
    
    deinit {
        cleanup()
    }

    func setupFormatDescription(from sampleBuffer: CMSampleBuffer, outputDimensions: CGSize) {
        if outputFormatDescription == nil {
            for filter in filters {
                filter.setupFormatDescription(from: sampleBuffer, outputDimensions: outputDimensions)
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
        for filter in filters {
            filter.cleanup()
        }
    }
}
