//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import UIKit
import XCTest

final class MMCQTests: XCTestCase {
    
    private let testImage = KanvasImages.shared.confirmImage
    
    func testQuantize() {
        guard let image = testImage,
            let bytes = ColorThief.makeBytes(from: image),
            let colorMap = MMCQ.quantize(bytes, quality: 1, ignoreWhite: false, maxColors: 3) else { return }
        
        let palette = colorMap.makePalette()
        let colors = palette.map { $0.makeUIColor() }
        let expectedColors = [UIColor(hex: "#040404"),
                              UIColor(hex: "#ebebeb"),
                              UIColor(hex: "#747474"),
                              UIColor(hex: "#6c6c6c")]
        
        XCTAssertEqual(colors, expectedColors, "Expected different colors")
    }
    
    func testVBox() {
        let vbox = MMCQ.VBox(rMin: 0, rMax: 0, gMin: 0, gMax: 0, bMin: 0, bMax: 0, histogram: [0,0,0,0,0,0,0,0,0,0])
        
        let color = vbox.getAverage().makeUIColor()
        let expectedColor = UIColor(hex: "#040404")
        XCTAssertEqual(color, expectedColor, "Expected different colors")
    }
    
    func testColorMap() {
        let colorMap = MMCQ.ColorMap().makeNearestColor(to: MMCQ.Color(r: 0, g: 0, b: 0))
        let color = colorMap.makeUIColor()
        let expectedColor = UIColor(hex: "#000000")
        
        XCTAssertEqual(color, expectedColor, "Expected different colors")
    }
}
