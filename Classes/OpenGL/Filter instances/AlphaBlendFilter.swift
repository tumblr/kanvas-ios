//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import OpenGLES
import GLKit

/// Alpha Blend Filter
final class AlphaBlendFilter: Filter {

    private let pixelBuffer: CVPixelBuffer
    private let overlayDimensions: CGSize
    private var uniformTexture: GLint = 0
    private var uniformOverlayScale: GLint = 0

    init(glContext: EAGLContext?, pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
        self.overlayDimensions = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        super.init(glContext: glContext, transform: nil)
    }

    override func setupShader() {
        if let fragment = Shader.getSourceCode("alpha_blend", type: .fragment),
            let vertex = Shader.getSourceCode("base_filter", type: .vertex),
            let shader = Shader(vertexShader: vertex, fragmentShader: fragment) {
            uniformTexture = GLU.getUniformLocation(shader.program, "textureOverlay")
            uniformOverlayScale = GLU.getUniformLocation(shader.program, "overlayScale")
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
                                                           overlayDimensions.width.i,
                                                           overlayDimensions.height.i,
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
        glUniform1i(uniformTexture, 2)

        if let overlayScale = getOverlayScale() {
            glUniform2f(uniformOverlayScale, overlayScale.width.f, overlayScale.height.f)
        }
    }

    private func getOverlayScale() -> CGSize? {
        var overlayScale = CGSize()
        let cropScaleAmount = CGSize(width: overlayDimensions.width / outputDimensions.width, height: overlayDimensions.height / outputDimensions.height)
        if cropScaleAmount.height > cropScaleAmount.width {
            overlayScale.width = overlayDimensions.width / (outputDimensions.width * cropScaleAmount.height)
            overlayScale.height = 1.0
        }
        else {
            overlayScale.width = 1.0
            overlayScale.height = overlayDimensions.height / (outputDimensions.height * cropScaleAmount.width)
        }
        return overlayScale
    }
}
