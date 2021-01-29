//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
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
