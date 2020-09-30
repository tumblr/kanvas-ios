//
//  Array+MoveTests.swift
//  KanvasCameraExampleTests
//
//  Created by Daniela Riesgo on 09/10/2018.
//  Copyright © 2018 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest

final class ArrayMoveTests: XCTestCase {

    // MARK: - #.move(from:to:)
    func testMoveAltersElementToNewIndex() {
        var array = ["a", "b", "c"]
        array.move(from: 1, to: 2)
        XCTAssertEqual(array.index(of: "b"), 2, "Expected index to be 2 after movement.")
    }

    func testMoveDoesntAlterQuantity() {
        var array = ["a", "b", "c"]
        array.move(from: 1, to: 2)
        XCTAssertEqual(array.count, 3, "Expected array's count to be unaltered.")
    }

    func testMoveDoesntAlterOrderOfOthers() {
        var array = [1, 2, 3, 4]
        array.move(from: 1, to: 3)
        XCTAssertEqual(array[0], 1, "Expected move to not alter other elements.")
        XCTAssertEqual(array[1], 3, "Expected move to not alter other elements.")
        XCTAssertEqual(array[2], 4, "Expected move to not alter other elements.")
    }

}
