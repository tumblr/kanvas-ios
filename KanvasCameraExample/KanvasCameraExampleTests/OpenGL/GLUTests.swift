//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

class GLUTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCompileShader() {
        var shader: GLuint = 0
        let fragmentShader = "precision mediump float;\nvoid main() {\n  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n}"
        let cs = (fragmentShader as NSString).utf8String
        var buffer = UnsafePointer(UnsafeMutablePointer<Int8>(mutating: cs))
        GLU.compileShader(GL_FRAGMENT_SHADER.ui, 1, &buffer, &shader)
    }

}
