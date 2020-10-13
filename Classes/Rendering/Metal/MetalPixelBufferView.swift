//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import MetalKit
import GLKit

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
    
    var mediaTransform: GLKMatrix4?
    var isPortrait: Bool = true
    
    init(context: MetalContext) {
        self.context = context
        super.init(frame: .zero, device: context.device)
        self.contentMode = .scaleAspectFit
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
        
        var width = CVPixelBufferGetWidth(pixelBufferToDraw)
        var height = CVPixelBufferGetHeight(pixelBufferToDraw)
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
        
        if isPortrait && width > height {
            (width, height) = (height, width)
        }
        
        renderEncoder.encode(commandBuffer: commandBuffer,
                             inputTexture: metalTexture,
                             currentRenderPassDescriptor: currentRenderPassDescriptor,
                             shaderContext: shaderContext,
                             aspectRatio: CGFloat(height) / CGFloat(width),
                             textureTransform: mediaTransform)
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilScheduled()
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
