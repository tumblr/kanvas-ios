//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import GLKit

class MetalFilter: FilterProtocol {
    var outputFormatDescription: CMFormatDescription?
    var transform: GLKMatrix4?
    var switchInputDimensions: Bool = false

    private let context: MetalContext
    private var shaderContext = ShaderContext()
    private let computePipelineState: MTLComputePipelineState
    private var offScreenTexture: MTLTexture?
    private var offScreenBuffer: CVPixelBuffer?
    private let threadgroupSize = MTLSize(width: 16, height: 16, depth: 1)
    private var threadgroupCount: MTLSize = MTLSize(width: 0, height: 0, depth: 0)
    
    init(context: MetalContext, kernelFunctionName: String) {
        self.context = context
        
        guard
            let kernelFunction = context.library.makeFunction(name: kernelFunctionName),
            let computePipelineState = try? context.device.makeComputePipelineState(function: kernelFunction)
        else {
            fatalError("Couldn't setup compute pipeline for \(kernelFunctionName)")
        }
        self.computePipelineState = computePipelineState
    }
    
    func setupFormatDescription(from sampleBuffer: CMSampleBuffer, transform: GLKMatrix4?, outputDimensions: CGSize) {
        if outputFormatDescription == nil, let inputFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let inputDimensionsCM = CMVideoFormatDescriptionGetDimensions(inputFormatDescription)
            let inputDimensions = CGSize(width: inputDimensionsCM.width.g, height: inputDimensionsCM.height.g)
            setupFormatDescription(inputDimensions: inputDimensions, transform: transform, outputDimensions: outputDimensions)
        }
    }
    
    func setupFormatDescription(inputDimensions: CGSize, transform: GLKMatrix4?, outputDimensions: CGSize) {
        threadgroupCount = {
            var size = MTLSize()
            size.width = (Int(outputDimensions.width) + threadgroupSize.width - 1) / threadgroupSize.width
            size.height = (Int(outputDimensions.height) + threadgroupSize.height - 1) / threadgroupSize.height
            size.depth = 1
            return size
        }()
        
        let attributes = [
            kCVPixelBufferMetalCompatibilityKey: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,
                            Int(outputDimensions.width),
                            Int(outputDimensions.height),
                            kCVPixelFormatType_32BGRA,
                            attributes as CFDictionary,
                            &pixelBuffer)
        
        guard let offScreenPixelBuffer = pixelBuffer else {
            return
        }
        let textureCache = context.textureCache
        
        let width = CVPixelBufferGetWidth(offScreenPixelBuffer)
        let height = CVPixelBufferGetHeight(offScreenPixelBuffer)
        
        var cvTextureOut: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               textureCache,
                                                               offScreenPixelBuffer,
                                                               nil,
                                                               .bgra8Unorm,
                                                               width,
                                                               height,
                                                               0,
                                                               &cvTextureOut)
        
        guard
            result == kCVReturnSuccess,
            let cvTextureUnwrapped = cvTextureOut,
            let offScreenTexture = CVMetalTextureGetTexture(cvTextureUnwrapped)
        else {
            return
        }
        
        self.offScreenBuffer = offScreenPixelBuffer
        self.offScreenTexture = offScreenTexture
        
        var outputFormatDescription: CMFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: offScreenPixelBuffer, formatDescriptionOut: &outputFormatDescription)
        self.outputFormatDescription = outputFormatDescription
    }
    
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer?, time: TimeInterval) -> CVPixelBuffer? {
        guard
            let commandBuffer = context.commandQueue.makeCommandBuffer(),
            let computeEncoder = commandBuffer.makeComputeCommandEncoder(),
            let pixelBuffer = pixelBuffer,
            let offScreenTexture = offScreenTexture
        else {
            return nil
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var cvTexture: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               context.textureCache,
                                                               pixelBuffer,
                                                               nil,
                                                               .bgra8Unorm,
                                                               width,
                                                               height,
                                                               0,
                                                               &cvTexture)
        guard
            let unwrappedCVTexture = cvTexture,
            let inputTexture = CVMetalTextureGetTexture(unwrappedCVTexture),
            result == kCVReturnSuccess
        else {
            return nil
        }
        
        self.shaderContext = ShaderContext(time: Float(time))
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setTexture(inputTexture, index: 0)
        computeEncoder.setTexture(offScreenTexture, index: 1)
        computeEncoder.setBytes(&shaderContext,
                                 length: MemoryLayout<ShaderContext>.stride,
                                 index: 0)
        computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
        computeEncoder.endEncoding()
        commandBuffer.commit()
        
        return offScreenBuffer
    }
    
    func cleanup() {
    }
}
