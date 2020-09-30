//
//  IndexPath+OrderTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 21/06/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest

final class IndexPathOrderTests: XCTestCase {
    
    // MARK: - #.move(from:to:)
    func testNext() {
        let indexPath = IndexPath(item: 0, section: 0)
        let nextIndexPath = indexPath.next()
        XCTAssertEqual(nextIndexPath.item, 1, "Expected item to be 1.")
    }
    
    func testPrevious() {
        let indexPath = IndexPath(item: 2, section: 0)
        let previousIndexPath = indexPath.previous()
        XCTAssertEqual(previousIndexPath.item, 1, "Expected item to be 1.")
    }
    
    func testSectionWithNext() {
        let indexPath = IndexPath(item: 0, section: 0)
        let nextIndexPath = indexPath.next()
        XCTAssertEqual(nextIndexPath.section, 0, "Expected section to be 0.")
    }
    
    func testSectionWithPrevious() {
        let indexPath = IndexPath(item: 0, section: 0)
        let previousIndexPath = indexPath.previous()
        XCTAssertEqual(previousIndexPath.section, 0, "Expected section to be 0.")
    }
}
