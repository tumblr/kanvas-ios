//
//  ClosedRange+ClampTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 26/10/2018.
//  Copyright © 2018 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest

final class ClosedRangeTests: XCTestCase {
    
    func testClampWithValueBetweenRange() {
        let range = (1 ... 10)
        let middleValue = 5
        let result = range.clamp(middleValue)
        XCTAssertEqual(result, middleValue, "Expected to return 5.")
    }
    
    func testClampWithValueBelowRange() {
        let range = (10 ... 20)
        let result = range.clamp(2)
        XCTAssertEqual(result, range.lowerBound, "Expected to return lower bound of the range (10).")
    }
    
    func testClampWithValueAboveRange() {
        let range = (10 ... 20)
        let result = range.clamp(30)
        XCTAssertEqual(result, range.upperBound, "Expected to return upper bound of the range (20).")
    }
}
