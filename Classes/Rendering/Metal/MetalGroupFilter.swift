//
//  MetalGroupFilter.swift
//  KanvasCamera
//
//  Created by Taichi Matsumoto on 7/24/20.
//

import AVFoundation
import GLKit

class MetalGroupFilter: FilterProtocol {
    var outputFormatDescription: CMFormatDescription? {
        return filters.last?.outputFormatDescription
    }
    var transform: GLKMatrix4?
    var switchInputDimensions: Bool {
        get {
            return filters.first?.switchInputDimensions ?? false
        }
        set {
            filters.first?.switchInputDimensions = newValue
        }
    }
    
    private let filters: [MetalFilter]
    
    init(filters: [MetalFilter]) {
        self.filters = filters
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
