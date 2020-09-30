//
//  FilterFactoryTests.swift
//  KanvasCameraExampleTests
//

@testable import KanvasCamera
import XCTest

class FilterFactoryTests: XCTestCase {

    func testCreateFilter() {
        let glContext = EAGLContext(api: .openGLES3) ?? nil
        let filterFactory = FilterFactory(glContext: glContext, metalContext: nil, filterPlatform: .openGL)
        _ = filterFactory.createFilter(type: .lego)
    }

    func testFilterType() {
        XCTAssertEqual(FilterType.lego.key(), "lego")
    }

}
