//
//  Mirror4Filter.swift
//  KanvasCamera
//

import Foundation

/// Mirror Four Filter
final class MirrorFourOpenGLFilter: OpenGLFilter {

    override func setupShader() {
        let fragment = Shader.getSourceCode("mirror4", type: .fragment)
        let vertex = Shader.getSourceCode("base_filter", type: .vertex)
        if let fragment = fragment, let vertex = vertex {
            let shader = Shader(vertexShader: vertex, fragmentShader: fragment)
            self.shader = shader
        }
    }
}
