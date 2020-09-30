//
//  UIImage+DominantColorsTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 03/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest

final class UIImageDominantColorsTests: XCTestCase {
    
    func testDominantColors() {
        guard let image = KanvasCameraImages.confirmImage else { return }
        let colors = image.getDominantColors(count: 3)
                
        let expectedColors = [UIColor(hex: "#24bbfa"),
                              UIColor(hex: "#040505"),
                              UIColor(hex: "#f4f9fc"),
                              UIColor(hex: "#146c8c")]
        
        XCTAssertEqual(colors, expectedColors, "Expected different colors.")
    }
}
