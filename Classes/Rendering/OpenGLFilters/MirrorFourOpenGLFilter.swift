//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
