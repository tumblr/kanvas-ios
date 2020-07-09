//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import GLKit

/// A filter that renders shaders in a chain, with one output leading to the next
class GroupOpenGLFilter: FilterProtocol {

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
        return filters.last?.outputFormatDescription
    }

    var transform: GLKMatrix4? {
        return filters.first?.transform
    }

    private var filters: [FilterProtocol] = []
    
    init(filters: [FilterProtocol]) {
        self.filters = filters
    }
    
    deinit {
        cleanup()
    }

    func setupFormatDescription(from sampleBuffer: CMSampleBuffer, transform: GLKMatrix4?, outputDimensions: CGSize) {
        if outputFormatDescription == nil, let inputFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let inputDimensionsCM = CMVideoFormatDescriptionGetDimensions(inputFormatDescription)
            let inputDimensions = CGSize(width: inputDimensionsCM.width.g, height: inputDimensionsCM.height.g)
            setupFormatDescription(inputDimensions: inputDimensions, transform: transform, outputDimensions: outputDimensions)
        }
    }

    func setupFormatDescription(inputDimensions: CGSize, transform: GLKMatrix4?, outputDimensions: CGSize) {
        var inputDimensions = inputDimensions
        var transform = transform
        var outputDimensions = outputDimensions
        for filter in filters {
            filter.setupFormatDescription(inputDimensions: inputDimensions, transform: transform, outputDimensions: outputDimensions)
            transform = nil
            outputDimensions = .zero
            if let desc = filter.outputFormatDescription {
                let dim = CMVideoFormatDescriptionGetDimensions(desc)
                inputDimensions = CGSize(width: dim.width.d, height: dim.height.d)
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
