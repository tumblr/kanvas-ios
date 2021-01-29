//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

final class CALayerColorTests: XCTestCase {
    
    private func newView() -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        view.backgroundColor = .blue
        return view
    }
    
    func testColor() {
        let view = newView()
        let point = CGPoint(x: 10, y: 10)
        let color = view.layer.getColor(from: point)
        XCTAssertEqual(color, .blue, "Expected color to be blue.")
    }
}
