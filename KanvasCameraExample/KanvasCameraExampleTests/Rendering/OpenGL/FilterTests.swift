//
//  FilterTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 2/20/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest

class FilterTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
        let context = EAGLContext(api: .openGLES3)
        let _ = OpenGLFilter(glContext: context)
    }

}
