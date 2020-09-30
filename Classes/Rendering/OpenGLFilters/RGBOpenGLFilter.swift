//
//  RGBFilter.swift
//  KanvasCamera
//

import Foundation

/// RGB Filter
final class RGBOpenGLFilter: OpenGLFilter {

    override func setupShader() {
        let fragment = Shader.getSourceCode("rgb", type: .fragment)
        let vertex = Shader.getSourceCode("base_filter", type: .vertex)
        if let fragment = fragment, let vertex = vertex {
            let shader = Shader(vertexShader: vertex, fragmentShader: fragment)
            self.shader = shader
        }
    }

    override func updateUniforms() {
        shader?.setFloatUniform(key: "time", value: Float(time))
    }
}
