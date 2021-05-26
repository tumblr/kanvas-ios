//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import MetalKit
import GLKit
import MetalPerformanceShaders

struct ShaderContext {
    var time: Float = 0.0
}

final class MetalPixelBufferView: MTKView {
    private var shaderContext = ShaderContext()
    private let context: CIContext
    private let commandQueue: MTLCommandQueue

    private var image: CIImage?

    init() {
        let device = MTLCreateSystemDefaultDevice()!
        self.context = CIContext(mtlDevice: device, options: [.cacheIntermediates: false])
        mediaContentMode = .scaleToFill
        isPortrait = false
        commandQueue = device.makeCommandQueue()!
        super.init(frame: .zero, device: device)
        framebufferOnly = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let size = rect.size
        let rd = CIRenderDestination(width: Int(size.width * UIScreen.main.nativeScale), height: Int(size.height * UIScreen.main.nativeScale), pixelFormat: .rgba16Float, commandBuffer: nil, mtlTextureProvider: {
            return self.currentDrawable!.texture
        })

        let scale = CIFilter.lanczosScaleTransform()
        scale.inputImage = image
        scale.scale = Float(UIScreen.main.nativeScale)

        if let image = image {
            try! context.startTask(toRender: image, from: image.extent, to: rd, at: rect.origin)
        }

        let cmdBuf = commandQueue.makeCommandBuffer()
        cmdBuf?.present(currentDrawable as! MTLDrawable)
        cmdBuf?.commit()
    }

    var mediaTransform: GLKMatrix4?

    var mediaContentMode: UIView.ContentMode

    var isPortrait: Bool
}

extension MetalPixelBufferView: PixelBufferView {
    func displayImage(_ image: CIImage) {
        self.image = image
    }

    func displayPixelBuffer(_ pixelBuffer: CVPixelBuffer) {

    }

    func reset() {

    }

    func flushPixelBufferCache() {
        image = nil
    }
}
