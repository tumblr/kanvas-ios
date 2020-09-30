//
//  Mirror2Filter.swift
//  KanvasCamera
//

import Foundation

/// Mirror Two Filter
final class MirrorTwoOpenGLFilter: OpenGLFilter {
    
    override func setupShader() {
        let fragment = Shader.getSourceCode("mirror2", type: .fragment)
        let vertex = Shader.getSourceCode("base_filter", type: .vertex)
        if let fragment = fragment, let vertex = vertex {
            let shader = Shader(vertexShader: vertex, fragmentShader: fragment)
            self.shader = shader
        }
    }
}
