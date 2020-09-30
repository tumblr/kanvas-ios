//
//  MetalRenderEncoder.swift
//  KanvasCamera
//
//  Created by Taichi Matsumoto on 7/1/20.
//

import Metal

// Take care of metal render pipeline
final class MetalRenderEncoder {
    let renderPipelineState: MTLRenderPipelineState
    let device: MTLDevice
    var shaderContext = ShaderContext()

    init(device: MTLDevice, library: MTLLibrary) {
        self.device = device

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.sampleCount = 1
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.depthAttachmentPixelFormat = .invalid
        renderPipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexIdentity")
        renderPipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentIdentity")
        
        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderPipelineDescriptor) else {
            fatalError("cannot create render pipeline state")
        }
        self.renderPipelineState = renderPipelineState
    }
    
    func encode(commandBuffer: MTLCommandBuffer,
                inputTexture: MTLTexture,
                currentRenderPassDescriptor: MTLRenderPassDescriptor?,
                shaderContext: ShaderContext) {
        guard let currentRenderPassDescriptor = currentRenderPassDescriptor else {
            return
        }

        self.shaderContext = shaderContext
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        renderEncoder?.setRenderPipelineState(renderPipelineState)
        renderEncoder?.setFragmentTexture(inputTexture, index: 0)
        renderEncoder?.setFragmentBytes(&self.shaderContext,
                                        length: MemoryLayout<ShaderContext>.stride,
                                        index: 0)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        renderEncoder?.endEncoding()
    }
}
