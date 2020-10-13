//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Metal
import GLKit

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
                shaderContext: ShaderContext,
                aspectRatio: CGFloat,
                textureTransform: GLKMatrix4? = nil) {
        guard let currentRenderPassDescriptor = currentRenderPassDescriptor else {
            return
        }

        self.shaderContext = shaderContext
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        renderEncoder?.setRenderPipelineState(renderPipelineState)
        var vertex = createVertex(aspectRatio: aspectRatio)
        renderEncoder?.setVertexBytes(&vertex,
                                      length: MemoryLayout<Float>.size * vertex.count,
                                      index: 0)
        var textureCoordinates = createTextureCoordinates(textureTransform: textureTransform)
        renderEncoder?.setVertexBytes(&textureCoordinates,
                                      length: MemoryLayout<Float>.size * textureCoordinates.count,
                                      index: 1)
        renderEncoder?.setFragmentTexture(inputTexture, index: 0)
        renderEncoder?.setFragmentBytes(&self.shaderContext,
                                        length: MemoryLayout<ShaderContext>.stride,
                                        index: 0)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        renderEncoder?.endEncoding()
    }
    
    private func createTextureCoordinates(textureTransform: GLKMatrix4?) -> [Float] {
        let baseCoordinates: [Float] = [
            0.0, 1.0,
            1.0, 1.0,
            0.0, 0.0,
            1.0, 0.0
        ]

        guard let textureTransform = textureTransform else {
            return baseCoordinates
        }
        
        let degrees = round(Double(asin(textureTransform.m01)) / (Double.pi / 180.0))
        if degrees == 90 {
            return [
                1.0, 1.0,
                1.0, 0.0,
                0.0, 1.0,
                0.0, 0.0
            ]
        }
        else if degrees == -90 {
            return [
                0.0, 0.0,
                0.0, 1.0,
                1.0, 0.0,
                1.0, 1.0
            ]
        }
        
        return baseCoordinates
    }
    
    private func createVertex(aspectRatio: CGFloat) -> [Float] {
        var baseVertex: [[Float]] = [
            [-1.0, -1.0, 0.0, 1.0],
            [ 1.0, -1.0, 0.0, 1.0],
            [-1.0,  1.0, 0.0, 1.0],
            [ 1.0,  1.0, 0.0, 1.0]
        ]
        
        if aspectRatio >= 1.0 {
            return baseVertex.flatMap { $0 }
        }
        
        for i in 0..<baseVertex.count {
            baseVertex[i][1] *= Float(aspectRatio) / 2
        }
        return baseVertex.flatMap { $0 }
    }
}
