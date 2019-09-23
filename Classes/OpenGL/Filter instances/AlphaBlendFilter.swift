//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import OpenGLES

/// Alpha Blend Filter
final class AlphaBlendFilter: Filter {

    let pixelBuffer: CVPixelBuffer
    let dimensions: CMVideoDimensions
    var frame: GLint = 0

    init(glContext: EAGLContext?, pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
        self.dimensions = CMVideoDimensions(width: Int32(CVPixelBufferGetWidth(pixelBuffer)), height: Int32(CVPixelBufferGetHeight(pixelBuffer)))
        super.init(glContext: glContext)
    }

    override func setupShader() {
        let fragment = Filter.loadShader("alpha_blend", type: .fragment)
        let vertex = Filter.loadShader("Base", type: .vertex)
        if let fragment = fragment, let vertex = vertex {
            let shader = Shader()
            shader.setProgram(vertexShader: vertex, fragmentShader: fragment)
            frame = GLU.getUniformLocation(shader.program, "texture2")
            self.shader = shader
        }
    }

    override func updateUniforms() {
        super.updateUniforms()

        guard let textureCache = textureCache else {
            return
        }

        var err: CVReturn = noErr
        var srcTexture: CVOpenGLESTexture? = nil

        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           textureCache,
                                                           pixelBuffer,
                                                           nil,
                                                           GL_TEXTURE_2D.ui,
                                                           GL_RGBA,
                                                           dimensions.width,
                                                           dimensions.height,
                                                           GL_BGRA.ui,
                                                           GL_UNSIGNED_BYTE.ui,
                                                           0,
                                                           &srcTexture)
        guard let sourceTexture = srcTexture, err == 0 else {
            print("Error at CVOpenGLESTextureCacheCreateTextureFromImage \(err)")
            return
        }

        glActiveTexture(GL_TEXTURE2.ui)
        glBindTexture(CVOpenGLESTextureGetTarget(sourceTexture), CVOpenGLESTextureGetName(sourceTexture))
        glUniform1i(frame, 2)
    }
}
