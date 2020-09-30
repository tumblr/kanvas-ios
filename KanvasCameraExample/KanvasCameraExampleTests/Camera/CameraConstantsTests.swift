//
//  CameraConstantsTests.swift
//  KanvasCameraExampleTests
//
//  Created by Tony Cheng on 8/31/18.
//  Copyright © 2018 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class CameraConstantsTests: XCTestCase {
    
    func testButtonSize() {
        XCTAssert(26.5 == CameraConstants.optionButtonSize, "Button size should match expected value")
    }

    func testOptionHorizontalMargin() {
        XCTAssert(24 == CameraConstants.optionHorizontalMargin, "Option horizontal margin should match expected value")
    }
    
    func testOptionVerticalMargin() {
        XCTAssert(24 == CameraConstants.optionVerticalMargin, "Option vertical margin should match expected value")
    }
    
    func testOptionSpacing() {
        XCTAssert(33 == CameraConstants.optionSpacing, "Option spacing should match expected value")
    }
}
