//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

final class LegoFilter: Filter {
    
    override func setupShader() {
        let fragment = Filter.loadShader("lego", type: .fragment)
        let vertex = Filter.loadShader("Base", type: .vertex)
        if let fragment = fragment, let vertex = vertex {
            let shader = Shader()
            shader.setProgram(vertexShader: vertex, fragmentShader: fragment)
            self.shader = shader
        }
    }
    
    override func updateUniforms() {
        if let width = outputWidth, let height = outputHeight {
            let resolution: [Float] = [Float(width), Float(height)]
            shader?.setFloat2Uniform(key: "iResolution", value: resolution)
        }
    }
}
