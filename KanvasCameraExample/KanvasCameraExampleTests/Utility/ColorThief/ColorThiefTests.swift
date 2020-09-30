//
//  ColorThiefTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 02/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class ColorThieftTests: XCTestCase {
    
    private let testImage = KanvasCameraImages.confirmImage
    
    func testGetPalette() {
        guard let image = testImage,
            let palette = ColorThief.getPalette(from: image, colorCount: 3, quality: 1, ignoreWhite: false) else { return }
        
        let colors = palette.map { $0.makeUIColor() }
        let expectedColors = [UIColor(hex: "#24bbfa"), UIColor(hex: "#040506"), UIColor(hex: "#f4f9fc"), UIColor(hex: "#145c7c")]
        
        XCTAssertEqual(colors, expectedColors, "Expected different colors")
    }
}
