//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

final class UIImageDominantColorsTests: XCTestCase {
    
    func testDominantColors() {
        guard let image = KanvasCameraImages.confirmImage else { return }
        let colors = image.getDominantColors(count: 3)
        
        print(colors.map { $0.hexString() })
        
        let expectedColors = [UIColor(hex: "#24bbfa"),
                              UIColor(hex: "#040505"),
                              UIColor(hex: "#f4f9fc"),
                              UIColor(hex: "#146c8c")]
        
        XCTAssertEqual(colors, expectedColors, "Expected different colors.")
    }
}
