//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import CoreVideo
import OpenGLES
import GLKit

/// Protocol for GLPixelBufferView
protocol GLPixelBufferViewDelegate: class {

    /// Called when the rendering rectangle changes
    func didRenderRectChange(rect: CGRect)
}

/// OpenGL view for rendering a buffer of pixels.
final class GLPixelBufferView: UIView, PixelBufferView {

    private weak var delegate: GLPixelBufferViewDelegate?

    private var renderShader: Shader?
    private var oglContext: EAGLContext?
    private var textureCache: CVOpenGLESTextureCache?
    private var width: GLint = 0
    private var height: GLint = 0

    private var frameBufferHandle: GLuint = 0
    private var colorBufferHandle: GLuint = 0

    private var uniformInputImageTexture: GLint = 0

    private var viewportRect: CGRect = .zero {
        didSet {
            if viewportRect != oldValue {
                var rect = viewportRect.applying(.init(scaleX: 1/contentScaleFactor, y: 1/contentScaleFactor))
                // We need to round these values to prevent sub-pixel rounding errors.
                rect = CGRect(x: round(rect.origin.x), y: round(rect.origin.y), width: round(rect.width), height: round(rect.height))
                delegate?.didRenderRectChange(rect: rect)
            }
        }
    }

    private var mediaContentMode: UIView.ContentMode = .scaleAspectFill {
        didSet {
            guard mediaContentMode == .scaleAspectFill || mediaContentMode == .scaleAspectFit else {
                assertionFailure("GLPixelBufferView.mediaContentMode only supports scaleAspectFill and scaleAspectFit")
                return
            }
        }
    }
    
    var mediaTransform: GLKMatrix4?
    var isPortrait: Bool = true

    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }

    /// Initializes the OpenGL layer and context
    init(delegate: GLPixelBufferViewDelegate?, mediaContentMode: UIView.ContentMode = .scaleAspectFill) {
        self.delegate = delegate
        self.mediaContentMode = mediaContentMode
        super.init(frame: .zero)
        
        self.contentScaleFactor = UIScreen.main.nativeScale
        
        // Initialize OpenGLES 3
        let eaglLayer = self.layer as? CAEAGLLayer
        eaglLayer?.isOpaque = false
        eaglLayer?.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false,
                                         kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
        
        oglContext = EAGLContext(api: .openGLES3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// Initializes framebuffers, renderbuffers, and a tecture cache
    private func initializeBuffers() -> Bool {
        guard let oglContext = oglContext, let layer = self.layer as? CAEAGLLayer else {
            return false
        }
        
        var success = true
        
        glDisable(GL_DEPTH_TEST.ui)
        
        glGenFramebuffers(1, &frameBufferHandle)
        glBindFramebuffer(GL_FRAMEBUFFER.ui, frameBufferHandle)
        
        glGenRenderbuffers(1, &colorBufferHandle)
        glBindRenderbuffer(GL_RENDERBUFFER.ui, colorBufferHandle)
        
        oglContext.renderbufferStorage(GL_RENDERBUFFER.l, from: layer)
        
        glGetRenderbufferParameteriv(GL_RENDERBUFFER.ui, GL_RENDERBUFFER_WIDTH.ui, &width)
        glGetRenderbufferParameteriv(GL_RENDERBUFFER.ui, GL_RENDERBUFFER_HEIGHT.ui, &height)
        
        bail: repeat {
            glFramebufferRenderbuffer(GL_FRAMEBUFFER.ui, GL_COLOR_ATTACHMENT0.ui, GL_RENDERBUFFER.ui, colorBufferHandle)
            if glCheckFramebufferStatus(GL_FRAMEBUFFER.ui) != GL_FRAMEBUFFER_COMPLETE.ui {
                assertionFailure("Failure with framebuffer generation")
                success = false
                break bail
            }
            
            //  Create a new CVOpenGLESTexture cache
            let err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, oglContext as CVEAGLContext, nil, &textureCache)
            if err != 0 {
                assertionFailure("Error at CVOpenGLESTextureCacheCreate \(err)")
                success = false
                break bail
            }
            guard let vertexShaderSource = Shader.getSourceCode("base_render", type: .vertex),
                let fragmentShaderSource = Shader.getSourceCode("base_render", type: .fragment),
                let shader = Shader(vertexShader: vertexShaderSource, fragmentShader: fragmentShaderSource) else {
                    assertionFailure("Failed to load shader")
                    success = false
                    break bail
            }
            let uniformInputImageTexture = shader.getParameterLocation(name: "inputImageTexture")
            guard uniformInputImageTexture >= 0 else {
                assertionFailure("Failed to find inputImageTexture parameter")
                success = false
                break bail
            }

            self.renderShader = shader
            self.uniformInputImageTexture = uniformInputImageTexture
        } while false
        if !success {
            self.reset()
        }
        return success
    }

    deinit {
        self.reset()
    }
    
    // MARK: - PixelBufferView
    
    /// Renders a pixel buffer to a texture, which is applied to a 2D plane positioned to fill the entire view.
    func displayPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        guard let oglContext = oglContext else {
            return
        }
        
        let oldContext = EAGLContext.current()
        if oldContext !== oglContext {
            if !EAGLContext.setCurrent(oglContext) {
                assertionFailure("Problem with OpenGL context")
                return
            }
        }
        defer {
            glFlush()
            if oldContext !== oglContext {
                EAGLContext.setCurrent(oldContext)
            }
        }
        
        if frameBufferHandle == 0 {
            let success = self.initializeBuffers()
            if !success {
                assertionFailure("Problem initializing OpenGL buffers.")
                return
            }
        }
        
        // Create a CVOpenGLESTexture from a CVPixelBufferRef
        let frameWidth = CVPixelBufferGetWidth(pixelBuffer)
        let frameHeight = CVPixelBufferGetHeight(pixelBuffer)
        guard frameWidth > 0 && frameHeight > 0 else {
            assertionFailure("Provided pixel buffer has a zero width or height")
            return
        }

        var textureMaybe: CVOpenGLESTexture? = nil

        guard let textureCache = textureCache else {
            assertionFailure("Problem accessing texture cache")
            return
        }

        let err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               textureCache,
                                                               pixelBuffer,
                                                               nil,
                                                               GL_TEXTURE_2D.ui,
                                                               GL_RGBA,
                                                               frameWidth.i,
                                                               frameHeight.i,
                                                               GL_BGRA.ui,
                                                               GL_UNSIGNED_BYTE.ui,
                                                               0,
                                                               &textureMaybe)
        
        guard err == 0 else {
            assertionFailure("CVOpenGLESTextureCacheCreateTextureFromImage failed (error: \(err)")
            return
        }

        guard let texture = textureMaybe else {
            assertionFailure("CVOpenGLESTextureCacheCreateTextureFromImage failed to create texture")
            return
        }

        let screenSize = CGSize(width: width.g, height: height.g)
        let pixelBufferSize = CGSize(width: frameWidth, height: frameHeight)

        let viewportRect = { () -> CGRect in
            switch mediaContentMode {
            case .scaleAspectFit:
                return fitSourceInsideTarget(sourceSize: pixelBufferSize, targetSize: screenSize)
            case .scaleAspectFill:
                return fillSourceInsideTarget(sourceSize: pixelBufferSize, targetSize: screenSize)
            default:
                assertionFailure("Unsupported Media Content Mode \(mediaContentMode)")
                return .zero
            }
        }()

        self.viewportRect = viewportRect

        // Set the view port to the entire view
        glBindFramebuffer(GL_FRAMEBUFFER.ui, frameBufferHandle)
        glViewport(viewportRect.origin.x.i, viewportRect.origin.y.i, viewportRect.size.width.i, viewportRect.size.height.i)

        renderShader?.useProgram()
        glActiveTexture(GL_TEXTURE0.ui)
        glBindTexture(CVOpenGLESTextureGetTarget(texture), CVOpenGLESTextureGetName(texture))
        glUniform1i(uniformInputImageTexture, 0)


        // Set texture parameters
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MIN_FILTER.ui, GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MAG_FILTER.ui, GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_S.ui, GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_T.ui, GL_CLAMP_TO_EDGE)
        
        glVertexAttribPointer(ShaderConstants.attribVertex, 2, GL_FLOAT.ui, 0, 0, ShaderConstants.squareVertices)
        glEnableVertexAttribArray(ShaderConstants.attribVertex)

        // Perform a vertical flip by swapping the top left and the bottom left coordinate.
        // CVPixelBuffers have a top left origin and OpenGL has a bottom left origin.
        let textureVertices: [GLfloat] = [
            0.0, 1.0,
            1.0, 1.0,
            0.0, 0.0,
            1.0, 0.0,
        ]
        glVertexAttribPointer(ShaderConstants.attribTexturePosition, 2, GL_FLOAT.ui, 0, 0, textureVertices)
        glEnableVertexAttribArray(ShaderConstants.attribTexturePosition)
        
        glDrawArrays(GL_TRIANGLE_STRIP.ui, 0, 4)
        
        glBindRenderbuffer(GL_RENDERBUFFER.ui, colorBufferHandle)
        oglContext.presentRenderbuffer(GL_RENDERBUFFER.l)

        glBindTexture(CVOpenGLESTextureGetTarget(texture), 0)
        glBindTexture(GL_TEXTURE_2D.ui, 0)
    }
    
    /// Dispose of any OpenGL resources: ramebufers, renderbuffers, textureCache.
    /// Also resets the OpenGL context.
    func reset() {
        guard let oglContext = oglContext else {
            return
        }
        let oldContext = EAGLContext.current()
        if oldContext !== oglContext {
            if !EAGLContext.setCurrent(oglContext) {
                assertionFailure("Problem with OpenGL context")
                return
            }
        }
        if frameBufferHandle != 0 {
            glDeleteFramebuffers(1, &frameBufferHandle)
            frameBufferHandle = 0
        }
        if colorBufferHandle != 0 {
            glDeleteRenderbuffers(1, &colorBufferHandle)
            colorBufferHandle = 0
        }
        renderShader?.deleteProgram()
        flushPixelBufferCache()
        self.textureCache = nil
        if oldContext !== oglContext {
            EAGLContext.setCurrent(oldContext)
        }
    }

    /// Flushes the texture cache
    func flushPixelBufferCache() {
        if let textureCache = textureCache {
            CVOpenGLESTextureCacheFlush(textureCache, 0)
        }
    }
}
