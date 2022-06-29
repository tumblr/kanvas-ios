//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import XCTest

class GLUtilitiesTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCompileShader() {
        let fragmentShader = """
precision mediump float;
void main() {
  gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
}
"""
        XCTAssert(compileShader(fragmentShader) >= 0)
    }

    func compileShader(_ source: UnsafePointer<GLchar>?) -> GLuint {
        var shader: GLuint = 0
        var s = source
        GLU.compileShader(GL_FRAGMENT_SHADER.ui, 1, &s, &shader)
        return shader
    }

}
