//
// Created by Tony Cheng on 8/16/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class KanvasCameraStringsTests: XCTestCase {

    func testPhotoName() {
        XCTAssert(KanvasCameraStrings.name(for: .photo) == "Photo", "String does not match for photo")
    }

    func testGifName() {
        XCTAssert(KanvasCameraStrings.name(for: .loop) == "Loop", "String does not match for gif")
    }

    func testStopMotionName() {
        XCTAssert(KanvasCameraStrings.name(for: .stopMotion) == "Capture", "String does not match for stop motion")
    }

}
