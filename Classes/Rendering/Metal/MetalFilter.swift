//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import GLKit
import CoreImage

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
    private var threadgroupCount = MTLSize(width: 0, height: 0, depth: 0)
    private var overlayBuffer: CVPixelBuffer?
    private var overlayTexture: MTLTexture?
    
    init(context: MetalContext?, kernelFunctionName: String, overlayBuffer: CVPixelBuffer?=nil) {
        guard
            let context = context,
            let kernelFunction = context.library.makeFunction(name: kernelFunctionName),
            let computePipelineState = try? context.device.makeComputePipelineState(function: kernelFunction)
        else {
            fatalError("Couldn't setup compute pipeline for \(kernelFunctionName)")
        }
        self.context = context
        self.computePipelineState = computePipelineState
        self.overlayBuffer = overlayBuffer
    }
    
    func setupFormatDescription(from sampleBuffer: CMSampleBuffer, transform: GLKMatrix4?, outputDimensions: CGSize) {
        if outputFormatDescription == nil, let inputFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let inputDimensionsCM = CMVideoFormatDescriptionGetDimensions(inputFormatDescription)
            let inputDimensions = CGSize(width: inputDimensionsCM.width.g, height: inputDimensionsCM.height.g)
            setupFormatDescription(inputDimensions: inputDimensions, transform: transform, outputDimensions: outputDimensions)
        }
    }
    
    func setupFormatDescription(inputDimensions: CGSize, transform: GLKMatrix4?, outputDimensions: CGSize) {
        let finalDimensions = outputDimensions == .zero ? inputDimensions : outputDimensions
        
        threadgroupCount = {
            var size = MTLSize()
            size.width = (Int(finalDimensions.width) + threadgroupSize.width - 1) / threadgroupSize.width
            size.height = (Int(finalDimensions.height) + threadgroupSize.height - 1) / threadgroupSize.height
            size.depth = 1
            return size
        }()
        
        let attributes = [
            kCVPixelBufferMetalCompatibilityKey: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,
                            Int(finalDimensions.width),
                            Int(finalDimensions.height),
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
        
        if let overlayBuffer = overlayBuffer,
            let pixelBuffer = overlayBuffer.resize(scale: (CGFloat(width) + UIScreen.main.scale) / CGFloat(CVPixelBufferGetWidth(overlayBuffer))) {
            
            var overlayTextureOut: CVMetalTexture?
            let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                   textureCache,
                                                                   pixelBuffer,
                                                                   nil,
                                                                   .bgra8Unorm,
                                                                   width,
                                                                   height,
                                                                   0,
                                                                   &overlayTextureOut)
            guard
                result == kCVReturnSuccess,
                let cvTextureUnwrapped = overlayTextureOut,
                let overlayTexture = CVMetalTextureGetTexture(cvTextureUnwrapped)
            else {
                return
            }
            self.overlayTexture = overlayTexture
        }
        
        var outputFormatDescription: CMFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: offScreenPixelBuffer,
                                                     formatDescriptionOut: &outputFormatDescription)
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
        
        var width = CVPixelBufferGetWidth(pixelBuffer)
        var height = CVPixelBufferGetHeight(pixelBuffer)
        var cvTexture: CVMetalTexture?
        
        var sourcePixelBuffer: CVPixelBuffer = pixelBuffer
        if width < offScreenTexture.width && height < offScreenTexture.height {
            // INFO: Resize input image so it has similar size as output buffer.
            //       This is necessary as the shader function "kernelIdentity" assumes the input texture has similar size as output texture size.
            //       Ideally we want to move this logic to the shader as GPU can execute scaling operation a lot faster,
            //       but I wasn't able to make sampler function work in a kernel shader. (Sampler is necessary to scale image)
            if let pixelBuffer = pixelBuffer.resize(scale: CGFloat(offScreenTexture.height) / CGFloat(height)) {
                sourcePixelBuffer = pixelBuffer
                width = CVPixelBufferGetWidth(sourcePixelBuffer)
                height = CVPixelBufferGetHeight(sourcePixelBuffer)
            }
        }
        
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               context.textureCache,
                                                               sourcePixelBuffer,
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
        if let overlayTexture = overlayTexture {
            computeEncoder.setTexture(overlayTexture, index: 2)
        }
        computeEncoder.setBytes(&shaderContext,
                                 length: MemoryLayout<ShaderContext>.stride,
                                 index: 0)
        computeEncoder.dispatchThreadgroups(threadgroupCount, threadsPerThreadgroup: threadgroupSize)
        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilScheduled()
        
        return offScreenBuffer
    }
    
    func cleanup() {
    }
}
