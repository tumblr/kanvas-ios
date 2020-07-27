//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Light Leaks Filter
final class LightLeaksOpenGLFilter: OpenGLFilter {

    override func setupShader() {
        let fragment = Shader.getSourceCode("light_leaks", type: .fragment)
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
