//
//  RGBATests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 05/02/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class RGBATests: XCTestCase {
    
    func testRGBA() {
        let rgba = RGBA(color: UIColor.blue)
        XCTAssertTrue(rgba.red == 0 && rgba.green == 0 && rgba.blue == 1 && rgba.alpha == 1, "RGBA values are not correct")
    }
    
    func testComponents() {
        let rgba: RGBA = UIColor.blue.rgbaComponents
        XCTAssertTrue(rgba.red == 0 && rgba.green == 0 && rgba.blue == 1 && rgba.alpha == 1, "RGBA values are not correct")
    }
}
