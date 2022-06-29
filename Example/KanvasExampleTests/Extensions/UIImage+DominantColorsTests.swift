//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import XCTest

final class UIImageDominantColorsTests: XCTestCase {
    
    func testDominantColors() {
        guard let image = KanvasImages.shared.confirmImage else { return }
        let colors = image.getDominantColors(count: 3)
                
        let expectedColors = [UIColor(hex: "#ebebeb"),
                              UIColor(hex: "#040404"),
                              UIColor(hex: "#545454"),
                              UIColor(hex: "#343434")]
        
        XCTAssertEqual(colors, expectedColors, "Expected different colors.")
    }
}
