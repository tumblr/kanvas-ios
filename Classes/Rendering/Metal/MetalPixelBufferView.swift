//
//  MetalPixelBufferView.swift
//  KanvasCamera
//
//  Created by Taichi Matsumoto on 6/28/20.
//

import MetalKit

struct ShaderContext {
    var time: Float = 0.0
}

final class MetalPixelBufferView: MTKView {
    private var shaderContext = ShaderContext()
    private let context: MetalContext
    private var pixelBufferToDraw: CVPixelBuffer?
    private lazy var renderEncoder: MetalRenderEncoder = {
        MetalRenderEncoder(device: context.device, library: context.library)
    }()
    
    init(context: MetalContext) {
        self.context = context
        super.init(frame: .zero, device: context.device)
        print(renderEncoder.device)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard
            let currentRenderPassDescriptor = currentRenderPassDescriptor,
            let drawable = currentDrawable,
            let commandBuffer = context.commandQueue.makeCommandBuffer(),
            let pixelBufferToDraw = pixelBufferToDraw
        else {
            return
        }
        
        let width = CVPixelBufferGetWidth(pixelBufferToDraw)
        let height = CVPixelBufferGetHeight(pixelBufferToDraw)
        var cvTexture: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               context.textureCache,
                                                               pixelBufferToDraw,
                                                               nil,
                                                               .bgra8Unorm,
                                                               width,
                                                               height,
                                                               0,
                                                               &cvTexture)
        guard
            let unwrappedCVTexture = cvTexture,
            let metalTexture = CVMetalTextureGetTexture(unwrappedCVTexture),
            result == kCVReturnSuccess
        else {
            print("Failed to create CVMetalTexture during draw process")
            return
        }
        
        renderEncoder.encode(commandBuffer: commandBuffer,
                             inputTexture: metalTexture,
                             currentRenderPassDescriptor: currentRenderPassDescriptor,
                             shaderContext: shaderContext)
        commandBuffer.present(drawable)
        commandBuffer.commit()
        self.pixelBufferToDraw = nil
    }
}

extension MetalPixelBufferView: PixelBufferView {
    func displayPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        // pixelBufferToDraw is nil out once the frame is rendered.
        // if a new frame comes in before the previous frame is rendered,
        // we simply skip it.
        guard pixelBufferToDraw == nil else {
            return
        }
        pixelBufferToDraw = pixelBuffer
    }
    
    func flushPixelBufferCache() { }
    
    func reset() { }
}
