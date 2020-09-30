//
//  LegoFilter.swift
//  KanvasCamera
//

import Foundation

/// Lego Filter
final class LegoOpenGLFilter: OpenGLFilter {
    
    override func setupShader() {
        let fragment = Shader.getSourceCode("lego", type: .fragment)
        let vertex = Shader.getSourceCode("base_filter", type: .vertex)
        if let fragment = fragment, let vertex = vertex {
            let shader = Shader(vertexShader: vertex, fragmentShader: fragment)
            self.shader = shader
        }
    }
    
    override func updateUniforms() {
        let resolution: [Float] = [Float(outputDimensions.width), Float(outputDimensions.height)]
        shader?.setFloat2Uniform(key: "iResolution", value: resolution)
    }
}
