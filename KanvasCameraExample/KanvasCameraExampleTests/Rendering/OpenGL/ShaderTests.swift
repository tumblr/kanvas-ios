//
//  ShaderTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 2/20/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest

class ShaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testShaderInit() {
        guard let vertexShaderCode = Shader.getSourceCode("base_filter", type: .vertex),
            let fragmentShaderCode = Shader.getSourceCode("base_filter", type: .fragment) else {
                XCTFail("Failed to load shader source code")
                return
        }
        let _ = Shader(vertexShader: vertexShaderCode, fragmentShader: fragmentShaderCode)
    }

}
