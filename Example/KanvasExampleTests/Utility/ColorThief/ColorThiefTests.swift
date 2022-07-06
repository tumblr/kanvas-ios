//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import UIKit
import XCTest

final class ColorThieftTests: XCTestCase {
    
    private let testImage = KanvasImages.shared.confirmImage
    
    func testGetPalette() {
        guard
            let image = testImage,
            let palette = ColorThief.getPalette(from: image, colorCount: 3, quality: 1, ignoreWhite: false)
        else {
            return
        }
        
        let colors = palette.map { $0.makeUIColor() }
        let expectedColors = [UIColor(hex: "#040404"),
                              UIColor(hex: "#ebebeb"),
                              UIColor(hex: "#747474"),
                              UIColor(hex: "#6c6c6c")]
        
        XCTAssertEqual(colors, expectedColors, "Expected different colors")
    }
}
