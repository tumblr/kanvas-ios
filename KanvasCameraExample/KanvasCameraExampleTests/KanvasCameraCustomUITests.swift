//
//  KanvasCameraCustomUI.swift
//  KanvasCameraExampleTests
//
//  Created by Brandon Titus on 7/10/20.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class KanvasCameraCustomUITests: XCTestCase {

    // test that values are set by KanvasCameraCustomUI as part of the example app
    func testDefaults() {
        XCTAssertEqual(KanvasCameraFonts.shared.editorFonts, KanvasCameraCustomUI.shared.cameraFonts().editorFonts)
        XCTAssertEqual(KanvasCameraColors.shared.backgroundColors, KanvasCameraCustomUI.shared.cameraColors().backgroundColors)
    }
}
