//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import OpenGLES
import GLKit

/// A basic filter implementation to render CVPixelBuffer
class OpenGLFilter: FilterProtocol {

    private let glContext: EAGLContext?
    private var renderTextureCache: CVOpenGLESTextureCache?
    private var bufferPool: CVPixelBufferPool?
    private var bufferPoolAuxAttributes: CFDictionary?
    private var offscreenBufferHandle: GLuint = 0
    private var uniformInputImageTexture: GLint = 0
    private var uniformTransform: GLint = 0

    var textureCache: CVOpenGLESTextureCache?

    /// The shader program to render the texture
    var shader: Shader?
    
    /// The output format description from a CMSampleBuffer
    private(set) var outputFormatDescription: CMFormatDescription?

    /// Time interval that the filter is running for
    var time: TimeInterval = 0

    /// Transformation matrix that should be used for this filter
    private(set) var transform: GLKMatrix4?

    /// Input dimensions
    private(set) var inputDimensions: CGSize = .zero

    /// Output dimensions
    private(set) var outputDimensions: CGSize = .zero

    /// Has already switched input dimensions
    private var switchedInputDimensions: Bool = false

    /// Switch the input dimensions when determining output dimensions
    var switchInputDimensions: Bool = false
    
    /// Initializer with glContext
    ///
    /// - Parameter glContext: The current EAGLContext. Should be the same for the whole program
    init(glContext: EAGLContext?) {
        self.glContext = glContext
    }
    
    /// Method to initialize the filter with the right output
    ///
    /// - Parameter sampleBuffer: the input sample buffer
    func setupFormatDescription(from sampleBuffer: CMSampleBuffer, transform: GLKMatrix4?, outputDimensions: CGSize) {
        if outputFormatDescription == nil, let inputFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let inputDimensionsCM = CMVideoFormatDescriptionGetDimensions(inputFormatDescription)
            let inputDimensions = CGSize(width: inputDimensionsCM.width.g, height: inputDimensionsCM.height.g)
            setupFormatDescription(inputDimensions: inputDimensions, transform: transform, outputDimensions: outputDimensions)
        }
    }

    func setupFormatDescription(inputDimensions: CGSize, transform: GLKMatrix4?, outputDimensions: CGSize) {
        deleteBuffers()

        var outputDimensionsNonZero = outputDimensions == .zero ? inputDimensions : outputDimensions
        if !switchedInputDimensions {
            if switchInputDimensions {
                outputDimensionsNonZero = CGSize(width: outputDimensionsNonZero.height, height: outputDimensionsNonZero.width)
            }
            switchedInputDimensions = true
        }
        self.inputDimensions = inputDimensions
        self.outputDimensions = outputDimensionsNonZero
        self.transform = transform
        guard initializeBuffers() else {
            assertionFailure("Problem initializing filter")
            return
        }
    }
    
    private func initializeBuffers() -> Bool {
        guard let glContext = glContext else {
            return false
        }
        
        let oldContext = EAGLContext.current()
        if oldContext !== glContext {
            let _ = EAGLContext.setCurrent(glContext)
        }
        
        defer {
            if oldContext !== glContext {
                _ = EAGLContext.setCurrent(oldContext)
            }
        }
        
        glDisable(GL_DEPTH_TEST.ui)
        glGenFramebuffers(1, &offscreenBufferHandle)
        glBindFramebuffer(GL_FRAMEBUFFER.ui, offscreenBufferHandle)

        guard inputDimensions != .zero && outputDimensions != .zero else {
            assertionFailure("Input and output dimensions cannot be zero")
            return false
        }
        
        do {
            var err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, glContext, nil, &textureCache)
            if err != 0 {
                throw GLError.setupError("Error at CVOpenGLESTextureCacheCreate")
            }
            
            err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, glContext, nil, &renderTextureCache)
            if err != 0 {
                throw GLError.setupError("Error at CVOpenGLESTextureCacheCreate")
            }
            
            setupShader()
            
            guard let shader = shader else {
                throw GLError.setupError("Problem initializing shader.")
            }
            uniformInputImageTexture = GLU.getUniformLocation(shader.program, "inputImageTexture")
            uniformTransform = GLU.getUniformLocation(shader.program, "transform")
            
            let maxRetainedBufferCount = ShaderConstants.retainedBufferCount
            bufferPool = createPixelBufferPool(outputDimensions.width.i,
                                               outputDimensions.height.i,
                                               FourCharCode(kCVPixelFormatType_32BGRA),
                                               Int32(maxRetainedBufferCount))
            if bufferPool == nil {
                throw GLError.setupError("Problem initializing a buffer pool.")
            }
            
            bufferPoolAuxAttributes = createPixelBufferPoolAuxAttributes(maxRetainedBufferCount)
            guard let bufferPool = bufferPool, let bufferPoolAttributes = bufferPoolAuxAttributes else {
                throw GLError.setupError("Problem allocating the pixel buffers")
            }
            preallocatePixelBuffersInPool(bufferPool, bufferPoolAttributes)
            
            var outputFormatDescription: CMFormatDescription? = nil
            var testPixelBuffer: CVPixelBuffer? = nil
            CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, bufferPool, bufferPoolAuxAttributes, &testPixelBuffer)
            guard let imageBuffer = testPixelBuffer else {
                throw GLError.setupError("Problem creating a pixel buffer.")
            }
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: imageBuffer, formatDescriptionOut: &outputFormatDescription)
            self.outputFormatDescription = outputFormatDescription
        }
        catch {
            deleteBuffers()
            return false
        }
        return true
    }
    
    // MARK: - pixel buffers
    private func createPixelBufferPool(_ width: Int32,
                                       _ height: Int32,
                                       _ pixelFormat: FourCharCode,
                                       _ maxBufferCount: Int32) -> CVPixelBufferPool? {
        var outputPool: CVPixelBufferPool? = nil
        
        let sourcePixelBufferOptions: NSDictionary = [kCVPixelBufferPixelFormatTypeKey: pixelFormat,
                                                      kCVPixelBufferWidthKey: width,
                                                      kCVPixelBufferHeightKey: height,
                                                      kCVPixelFormatOpenGLESCompatibility: true,
                                                      kCVPixelBufferIOSurfacePropertiesKey: NSDictionary()]

        let pixelBufferPoolOptions: NSDictionary = [kCVPixelBufferPoolMinimumBufferCountKey: maxBufferCount]
        
        CVPixelBufferPoolCreate(kCFAllocatorDefault, pixelBufferPoolOptions, sourcePixelBufferOptions, &outputPool)
        
        return outputPool
    }
    
    private func createPixelBufferPoolAuxAttributes(_ maxBufferCount: size_t) -> NSDictionary {
        return [kCVPixelBufferPoolAllocationThresholdKey: maxBufferCount]
    }
    
    private func preallocatePixelBuffersInPool(_ pool: CVPixelBufferPool, _ auxAttributes: NSDictionary) {
        // Preallocate buffers in the pool, since this is for real-time display/capture
        var pixelBuffers: [CVPixelBuffer] = []
        while true {
            var pixelBuffer: CVPixelBuffer? = nil
            let err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, pool, auxAttributes, &pixelBuffer)
            
            if err == kCVReturnWouldExceedAllocationThreshold {
                break
            }
            if err != noErr {
                assertionFailure("Error preallocating pixel buffers in pool")
            }
            else if let pixelBuffer = pixelBuffer {
                pixelBuffers.append(pixelBuffer)
            }
        }
        pixelBuffers.removeAll()
    }
    
    /// Should be overridden
    func setupShader() {
        let fragment = Shader.getSourceCode("base_filter", type: .fragment)
        let vertex = Shader.getSourceCode("base_filter", type: .vertex)
        if let fragment = fragment, let vertex = vertex {
            let shader = Shader(vertexShader: vertex, fragmentShader: fragment)
            self.shader = shader
        }
    }
    
    // MARK: - cleanup
    deinit {
        cleanup()
    }
    
    func cleanup() {
        deleteBuffers()
    }
    
    private func deleteBuffers() {
        let oldContext = EAGLContext.current()
        if oldContext != glContext {
            if !EAGLContext.setCurrent(glContext) {
                fatalError("Problem with OpenGL context")
            }
        }
        if offscreenBufferHandle != 0 {
            glDeleteFramebuffers(1, &offscreenBufferHandle)
            offscreenBufferHandle = 0
        }
        shader?.deleteProgram()
        shader = nil
        if textureCache != nil {
            textureCache = nil
        }
        if renderTextureCache != nil {
            renderTextureCache = nil
        }
        if bufferPool != nil {
            bufferPool = nil
        }
        if bufferPoolAuxAttributes != nil {
            bufferPoolAuxAttributes = nil
        }
        if outputFormatDescription != nil {
            outputFormatDescription = nil
        }
        switchedInputDimensions = false
        if oldContext !== glContext {
            _ = EAGLContext.setCurrent(oldContext)
        }
    }
    
    // MARK: - filters get rendered to a backing CVPixelBuffer
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer?, time: TimeInterval) -> CVPixelBuffer? {
        guard
            let shader = shader,
            let pixelBuffer = pixelBuffer,
            let textureCache = textureCache,
            let bufferPool = bufferPool,
            let renderTextureCache = renderTextureCache
        else {
            return nil
        }
        let oldContext = EAGLContext.current()
        if oldContext !== glContext {
            _ = EAGLContext.setCurrent(glContext)
        }
        defer {
            glFlush()
            if oldContext !== glContext {
                EAGLContext.setCurrent(oldContext)
            }
        }
        do {
            if offscreenBufferHandle == 0 {
                throw GLError.setupError("Uninitialized buffer")
            }
            if CVPixelBufferGetPixelFormatType(pixelBuffer) != OSType(kCVPixelFormatType_32BGRA) {
                throw GLError.setupError("Invalid pixel buffer format")
            }
            
            var err: CVReturn = noErr
            var srcTexture: CVOpenGLESTexture? = nil
            var dstTexture: CVOpenGLESTexture? = nil
            var dstPixelBuffer: CVPixelBuffer? = nil

            let srcDimensions = CMVideoDimensions(width: Int32(CVPixelBufferGetWidth(pixelBuffer)),
                                                  height: Int32(CVPixelBufferGetHeight(pixelBuffer)))
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               textureCache,
                                                               pixelBuffer,
                                                               nil,
                                                               GL_TEXTURE_2D.ui,
                                                               GL_RGBA,
                                                               srcDimensions.width,
                                                               srcDimensions.height,
                                                               GL_BGRA.ui,
                                                               GL_UNSIGNED_BYTE.ui,
                                                               0,
                                                               &srcTexture)
            guard let sourceTexture = srcTexture, err == 0 else {
                throw GLError.setupError("Error at CVOpenGLESTextureCacheCreateTextureFromImage \(err)")
            }
            
            err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, bufferPool, bufferPoolAuxAttributes, &dstPixelBuffer)
            if err == kCVReturnWouldExceedAllocationThreshold {
                // Flush the texture cache to potentially release the retained buffers and try again to create a pixel buffer
                CVOpenGLESTextureCacheFlush(renderTextureCache, 0)
                CVOpenGLESTextureCacheFlush(textureCache, 0)
                err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, bufferPool, bufferPoolAuxAttributes, &dstPixelBuffer)
            }
            if err != 0 {
                if err == kCVReturnWouldExceedAllocationThreshold {
                    throw GLError.setupError("Pool is out of buffers, dropping frame")
                }
                else {
                    throw GLError.setupError("Error at CVPixelBufferPoolCreatePixelBuffer")
                }
            }
            
            guard let destinationBuffer = dstPixelBuffer else {
                throw GLError.setupError("Destination buffer is unavailable")
            }
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               renderTextureCache,
                                                               destinationBuffer,
                                                               nil,
                                                               GL_TEXTURE_2D.ui,
                                                               GL_RGBA,
                                                               outputDimensions.width.i,
                                                               outputDimensions.height.i,
                                                               GL_BGRA.ui,
                                                               GL_UNSIGNED_BYTE.ui,
                                                               0,
                                                               &dstTexture)
            guard let destinationTexture = dstTexture, err == 0 else {
                throw GLError.setupError("Error at CVOpenGLESTextureCacheCreateTextureFromImage")
            }
            
            glBindFramebuffer(GL_FRAMEBUFFER.ui, offscreenBufferHandle)
            glViewport(0, 0, outputDimensions.width.i, outputDimensions.height.i)
            shader.useProgram()
            self.time = time
            updateUniforms()

            let transform = self.transform ?? GLKMatrix4Identity
            transform.unsafePointer { m in
                glUniformMatrix4fv(uniformTransform, 1, 0, m)
            }

            // Set up our destination pixel buffer as the framebuffer's render target.
            glActiveTexture(GL_TEXTURE0.ui)
            glBindTexture(CVOpenGLESTextureGetTarget(destinationTexture), CVOpenGLESTextureGetName(destinationTexture))
            glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MIN_FILTER.ui, GL_LINEAR)
            glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MAG_FILTER.ui, GL_LINEAR)
            glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_S.ui, GL_CLAMP_TO_EDGE)
            glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_T.ui, GL_CLAMP_TO_EDGE)
            glFramebufferTexture2D(GL_FRAMEBUFFER.ui, GL_COLOR_ATTACHMENT0.ui, CVOpenGLESTextureGetTarget(destinationTexture), CVOpenGLESTextureGetName(destinationTexture), 0)
            
            // Render our source pixel buffer.
            glActiveTexture(GL_TEXTURE1.ui)
            glBindTexture(CVOpenGLESTextureGetTarget(sourceTexture), CVOpenGLESTextureGetName(sourceTexture))
            glUniform1i(uniformInputImageTexture, 1)
            
            glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MIN_FILTER.ui, GL_LINEAR)
            glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_MAG_FILTER.ui, GL_LINEAR)
            glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_S.ui, GL_CLAMP_TO_EDGE)
            glTexParameteri(GL_TEXTURE_2D.ui, GL_TEXTURE_WRAP_T.ui, GL_CLAMP_TO_EDGE)
            
            glVertexAttribPointer(ShaderConstants.attribVertex, 2, GL_FLOAT.ui, 0, 0, ShaderConstants.squareVertices)
            glEnableVertexAttribArray(ShaderConstants.attribVertex)
            glVertexAttribPointer(ShaderConstants.attribTexturePosition, 2, GL_FLOAT.ui, 0, 0, ShaderConstants.textureVertices)
            glEnableVertexAttribArray(ShaderConstants.attribTexturePosition)
            
            glDrawArrays(GL_TRIANGLE_STRIP.ui, 0, 4)
            glBindTexture(CVOpenGLESTextureGetTarget(sourceTexture), 0)
            glBindTexture(CVOpenGLESTextureGetTarget(destinationTexture), 0)
            
            return dstPixelBuffer
        }
        catch let error {
            NSLog("error in filtering: \(error)")
            return nil
        }
    }

    // MARK: - uniforms
    /// This should be overridden by final class implementations
    func updateUniforms() {
        
    }

}
