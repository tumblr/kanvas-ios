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
    private let context: MetalContext
    private var pixelBufferToDraw: CVPixelBuffer?
    private lazy var renderEncoder: MetalRenderEncoder = {
        MetalRenderEncoder(device: context.device, library: context.library)
    }()
    
    var mediaTransform: GLKMatrix4?
    var isPortrait: Bool = true
    private(set) var mediaContentMode: UIView.ContentMode
    
    init(context: MetalContext, mediaContentMode: UIView.ContentMode) {
        self.context = context
        self.mediaContentMode = mediaContentMode
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

        let targetSize = CGSize(width: frame.width * contentScaleFactor, height: frame.height * contentScaleFactor)

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: metalTexture.pixelFormat, width: Int(targetSize.width), height: Int(targetSize.height), mipmapped: false)
        descriptor.usage = [.shaderWrite, .shaderRead, .renderTarget]

        guard let destinationTexture = device?.makeTexture(descriptor: descriptor) else {
            print("Resize destination texture's makeTexture failed")
            return
        }

        resize(targetSize: targetSize, commandBuffer: commandBuffer, sourceTexture: metalTexture, destinationTexture: destinationTexture)
        
        renderEncoder.encode(commandBuffer: commandBuffer,
                             inputTexture: destinationTexture,
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

extension MetalPixelBufferView {
    /// Resize a metal texture to a target size
    /// - Parameters:
    ///   - pixelBuffer: The pixel buffer containing the
    ///   - targetSize: Target size to scale and resize the `sourceTexture` to.
    ///   - commandBuffer: The command buffer to encode the scale transform to.
    ///   - sourceTexture: The metal texture to resize/scale.
    ///   - destinationTexture: The metal texture to encode the resulting scaled/resized image to.
    func resize(targetSize: CGSize, commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture, destinationTexture: MTLTexture) {
        let sourceWidth = sourceTexture.width
        let sourceHeight = sourceTexture.height
        let widthRatio = Double(targetSize.width) / Double(sourceWidth)
        let heightRatio = Double(targetSize.height) / Double(sourceHeight)
        let scaleX, scaleY, translateX, translateY: Double

        switch mediaContentMode {
        case .scaleToFill:
            scaleX = widthRatio
            scaleY = heightRatio
            translateX = 0
            translateY = 0
        case .scaleAspectFill:
            if heightRatio > widthRatio {
                scaleY = heightRatio
                scaleX = scaleY
                let currentWidth = Double(sourceWidth) * scaleX
                translateX = (Double(targetSize.width) - currentWidth) * 0.5
                translateY = 0
            } else {
                scaleX = widthRatio
                scaleY = scaleX
                let currentHeight = Double(sourceHeight) * scaleY
                translateY = (Double(targetSize.height) - currentHeight) * 0.5
                translateX = 0
            }
        case .scaleAspectFit:
            if heightRatio > widthRatio {
                scaleX = widthRatio
                scaleY = scaleX
                let currentHeight = Double(sourceHeight) * scaleY
                translateY = (Double(targetSize.height) - currentHeight) * 0.5
                translateX = 0
            } else {
                scaleY = heightRatio
                scaleX = scaleY
                let currentWidth = Double(sourceWidth) * scaleX
                translateX = (Double(targetSize.width) - currentWidth) * 0.5
                translateY = 0
            }
        default:
            scaleX = 0
            scaleY = 0
            translateX = 0
            translateY = 0
            // Only supports the scaling content modes.
        }

        var transform = MPSScaleTransform(scaleX: scaleX, scaleY: scaleY, translateX: translateX, translateY: translateY)
        let scale = MPSImageBilinearScale.init(device: device!)
        withUnsafePointer(to: &transform) { (transformPtr: UnsafePointer<MPSScaleTransform>) -> () in
            scale.scaleTransform = transformPtr
            scale.encode(commandBuffer: commandBuffer, sourceTexture: sourceTexture, destinationTexture: destinationTexture)
        }
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
