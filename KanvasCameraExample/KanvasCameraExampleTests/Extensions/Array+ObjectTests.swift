//
//  Array+ObjectTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 18/06/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest

final class ArrayObjectTests: XCTestCase {
    
    func testIndexWithinBounds() {
        let array = ["a", "b", "c", "d"]
        let element = array.object(at: 0)
        XCTAssertNotNil(element, "Expected element not to be nil.")
    }
    
    func testIndexAboveUpperBound() {
        let array = ["a", "b", "c", "d"]
        let element = array.object(at: 10)
        XCTAssertNil(element, "Expected element to be nil.")
    }
    
    func testIndexBelowLowerBound() {
        let array = ["a", "b", "c", "d"]
        let element = array.object(at: -5)
        XCTAssertNil(element, "Expected element to be nil.")
    }
}
