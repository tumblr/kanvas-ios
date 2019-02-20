//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import CoreVideo

final class GLPixelBufferView: UIView {
    private var renderShader: Shader?
    private var oglContext: EAGLContext?
    private var textureCache: CVOpenGLESTextureCache?
    private var width: GLint = 0
    private var height: GLint = 0
    private var frameBufferHandle: GLuint = 0
    private var colorBufferHandle: GLuint = 0
    private var videoFrame: GLint = 0
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentScaleFactor = UIScreen.main.nativeScale
        
        // Initialize OpenGL ES 3
        let eaglLayer = self.layer as? CAEAGLLayer
        eaglLayer?.isOpaque = true
        eaglLayer?.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false,
                                         kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
        
        oglContext = EAGLContext(api: .openGLES3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initializeBuffers() -> Bool {
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
                NSLog("Failure with framebuffer generation")
                success = false
                break bail
            }
            
            //  Create a new CVOpenGLESTexture cache
            let err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, oglContext as CVEAGLContext, nil, &textureCache)
            if err != 0 {
                NSLog("Error at CVOpenGLESTextureCacheCreate %d", err)
                success = false
                break bail
            }
            renderShader = Shader()
            if let renderShader = renderShader {
                videoFrame = renderShader.getParameterLocation(name: "videoframe")
            }
        } while false
        if !success {
            self.reset()
        }
        return success
    }
    
    func reset() {
        guard let oglContext = oglContext else {
            return
        }
        let oldContext = EAGLContext.current()
        if oldContext !== oglContext {
            if !EAGLContext.setCurrent(oglContext) {
                fatalError("Problem with OpenGL context")
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
        if let textureCache = textureCache {
            CVOpenGLESTextureCacheFlush(textureCache, 0)
            self.textureCache = nil
        }
        if oldContext !== oglContext {
            EAGLContext.setCurrent(oldContext)
        }
    }
    
    deinit {
        self.reset()
    }
    
    func displayPixelBuffer(_ pixelBuffer: CVPixelBuffer) {
        guard let oglContext = oglContext else {
            return
        }
        
        let oldContext = EAGLContext.current()
        if oldContext !== oglContext {
            if !EAGLContext.setCurrent(oglContext) {
                fatalError("Problem with OpenGL context")
            }
        }
        
        if frameBufferHandle == 0 {
            let success = self.initializeBuffers()
            if !success {
                NSLog("Problem initializing OpenGL buffers.")
                return
            }
        }
        
        // Create a CVOpenGLESTexture from a CVPixelBufferRef
        let frameWidth = CVPixelBufferGetWidth(pixelBuffer)
        let frameHeight = CVPixelBufferGetHeight(pixelBuffer)
        var textureMaybe: CVOpenGLESTexture? = nil

        guard let textureCache = textureCache else {
            NSLog("Problem accessing texture cache")
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
            NSLog("CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err)
            return
        }

        guard let texture = textureMaybe else {
            NSLog("CVOpenGLESTextureCacheCreateTextureFromImage failed to create texture")
            return
        }
        
        // Set the view port to the entire view
        glBindFramebuffer(GL_FRAMEBUFFER.ui, frameBufferHandle)
        glViewport(0, 0, width, height)
        
        renderShader?.useProgram()
        glActiveTexture(GL_TEXTURE0.ui)
        glBindTexture(CVOpenGLESTextureGetTarget(texture), CVOpenGLESTextureGetName(texture))
        glUniform1i(videoFrame, 0)
        
        // Set texture parameters
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MIN_FILTER.ui, GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MAG_FILTER.ui, GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_S.ui, GL_CLAMP_TO_EDGE)
        glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_T.ui, GL_CLAMP_TO_EDGE)
        
        glVertexAttribPointer(ShaderConstants.attribVertex, 2, GL_FLOAT.ui, 0, 0, ShaderConstants.squareVertices)
        glEnableVertexAttribArray(ShaderConstants.attribVertex)
        
        // Preserve aspect ratio; fill layer bounds
        var textureSamplingSize = CGSize()
        let cropScaleAmount = CGSize(width: self.bounds.size.width / frameWidth.g, height: self.bounds.size.height / frameHeight.g)
        if cropScaleAmount.height > cropScaleAmount.width {
            textureSamplingSize.width = self.bounds.size.width / (frameWidth.g * cropScaleAmount.height)
            textureSamplingSize.height = 1.0
        }
        else {
            textureSamplingSize.width = 1.0
            textureSamplingSize.height = self.bounds.size.height / (frameHeight.g * cropScaleAmount.width)
        }
        
        // Perform a vertical flip by swapping the top left and the bottom left coordinate.
        // CVPixelBuffers have a top left origin and OpenGL has a bottom left origin.
        let passThroughTextureVertices: [GLfloat] = [
            (1.0 - textureSamplingSize.width.f) / 2.0, (1.0 + textureSamplingSize.height.f) / 2.0, // top left
            (1.0 + textureSamplingSize.width.f) / 2.0, (1.0 + textureSamplingSize.height.f) / 2.0, // top right
            (1.0 - textureSamplingSize.width.f) / 2.0, (1.0 - textureSamplingSize.height.f) / 2.0, // bottom left
            (1.0 + textureSamplingSize.width.f) / 2.0, (1.0 - textureSamplingSize.height.f) / 2.0, // bottom right
        ]
        
        glVertexAttribPointer(ShaderConstants.attribTexturePosition, 2, GL_FLOAT.ui, 0, 0, passThroughTextureVertices)
        glEnableVertexAttribArray(ShaderConstants.attribTexturePosition)
        
        glDrawArrays(GL_TRIANGLE_STRIP.ui, 0, 4)
        
        glBindRenderbuffer(GL_RENDERBUFFER.ui, colorBufferHandle)
        oglContext.presentRenderbuffer(GL_RENDERBUFFER.l)

        glBindTexture(CVOpenGLESTextureGetTarget(texture), 0)
        glBindTexture(GL_TEXTURE_2D.ui, 0)

        if oldContext !== oglContext {
            EAGLContext.setCurrent(oldContext)
        }
    }
    
    func flushPixelBufferCache() {
        if let textureCache = textureCache {
            CVOpenGLESTextureCacheFlush(textureCache, 0)
        }
    }
    
}
