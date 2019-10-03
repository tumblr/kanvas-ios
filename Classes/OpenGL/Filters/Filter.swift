//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import OpenGLES

/// A basic filter implementation to render CVPixelBuffer
class Filter: FilterProtocol {

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
    var outputFormatDescription: CMFormatDescription?
    
    /// Output width for texture
    var outputWidth: Int?
    
    /// Output height for texture
    var outputHeight: Int?

    /// Time interval that the filter is running for
    var time: TimeInterval = 0

    var transform: Transformation?
    
    /// Initializer with glContext
    ///
    /// - Parameter glContext: The current EAGLContext. Should be the same for the whole program
    init(glContext: EAGLContext?, transform: Transformation?) {
        self.glContext = glContext
        self.transform = transform
    }
    
    /// Method to initialize the filter with the right output
    ///
    /// - Parameter sampleBuffer: the input sample buffer
    func setupFormatDescription(from sampleBuffer: CMSampleBuffer) {
        if outputFormatDescription == nil, let inputFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) {
            let dimensions = CMVideoFormatDescriptionGetDimensions(inputFormatDescription)
            deleteBuffers()
            if !initializeBuffersWithOutputDimensions(dimensions) {
                assertionFailure("Problem initializing filter")
            }
        }
    }
    
    private func initializeBuffersWithOutputDimensions(_ outputDimensions: CMVideoDimensions) -> Bool {
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
        
        do {
            self.outputWidth = Int(outputDimensions.width)
            self.outputHeight = Int(outputDimensions.height)
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
            bufferPool = createPixelBufferPool(outputDimensions.width, outputDimensions.height, FourCharCode(kCVPixelFormatType_32BGRA), Int32(maxRetainedBufferCount))
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
        let fragment = Filter.loadShader("Base", type: .fragment)
        let vertex = Filter.loadShader("Base", type: .vertex)
        if let fragment = fragment, let vertex = vertex {
            let shader = Shader()
            shader.setProgram(vertexShader: vertex, fragmentShader: fragment)
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
        if oldContext !== glContext {
            _ = EAGLContext.setCurrent(oldContext)
        }
    }
    
    // MARK: - filters get rendered to a backing CVPixelBuffer
    func processPixelBuffer(_ pixelBuffer: CVPixelBuffer?, time: TimeInterval) -> CVPixelBuffer? {
        guard let shader = shader, let pixelBuffer = pixelBuffer, let textureCache = textureCache, let outputFormatDescription = outputFormatDescription, let bufferPool = bufferPool, let renderTextureCache = renderTextureCache else {
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
            let srcDimensions = CMVideoDimensions(width: Int32(CVPixelBufferGetWidth(pixelBuffer)), height: Int32(CVPixelBufferGetHeight(pixelBuffer)))
            let dstDimensions = CMVideoFormatDescriptionGetDimensions(outputFormatDescription)
            if srcDimensions.width != dstDimensions.width || srcDimensions.height != dstDimensions.height {
                throw GLError.setupError("Invalid pixel buffer dimensions")
            }
            if CVPixelBufferGetPixelFormatType(pixelBuffer) != OSType(kCVPixelFormatType_32BGRA) {
                throw GLError.setupError("Invalid pixel buffer format")
            }
            
            var err: CVReturn = noErr
            var srcTexture: CVOpenGLESTexture? = nil
            var dstTexture: CVOpenGLESTexture? = nil
            var dstPixelBuffer: CVPixelBuffer? = nil
            
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
                                                               dstDimensions.width,
                                                               dstDimensions.height,
                                                               GL_BGRA.ui,
                                                               GL_UNSIGNED_BYTE.ui,
                                                               0,
                                                               &dstTexture)
            guard let destinationTexture = dstTexture, err == 0 else {
                throw GLError.setupError("Error at CVOpenGLESTextureCacheCreateTextureFromImage")
            }
            
            glBindFramebuffer(GL_FRAMEBUFFER.ui, offscreenBufferHandle)
            glViewport(0, 0, srcDimensions.width, srcDimensions.height)
            shader.useProgram()
            self.time = time
            updateUniforms()

            var transform = self.transform?.transformationMatrix ?? Transformation.identity
            GL_glUniformMatrix4fv(uniformTransform, 1, 0, &transform)

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
    
    /// Loads shaders as a String
    ///
    /// - Parameters:
    ///   - name: The name of the filter
    ///   - type: fragment or vertex
    /// - Returns: Bool for whether the shader was loaded
    class func loadShader(_ name: String, type: ShaderExtension) -> String? {
        let extString: String = type.rawValue
        guard let path = Bundle(for: Filter.self).path(forResource: String("\(ShaderConstants.shaderDirectory)/\(name)"), ofType: extString) else {
            return nil
        }
        do {
            let source = try String(contentsOfFile: path, encoding: .utf8)
            return source
        }
        catch {
            return nil
        }
    }
    
    // MARK: - uniforms
    /// This should be overridden by final class implementations
    func updateUniforms() {
        
    }

}
