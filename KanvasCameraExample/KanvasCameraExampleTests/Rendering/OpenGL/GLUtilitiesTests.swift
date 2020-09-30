//
//  GLUtilitiesTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 2/20/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
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
