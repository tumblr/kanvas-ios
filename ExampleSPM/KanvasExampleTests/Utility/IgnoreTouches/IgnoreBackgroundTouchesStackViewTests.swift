//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import UIKit
import XCTest

final class IgnoreBackgroundTouchesStackViewTests: XCTestCase {

    func newTouchesStackView() -> IgnoreBackgroundTouchesStackView {
        let view = IgnoreBackgroundTouchesStackView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        return view
    }

    func testTouchInBounds() {
        let view = newTouchesStackView()
        let point = CGPoint(x: 20, y: 20)
        let touched = view.hitTest(point, with: nil)
        XCTAssertNil(touched, "The stack view should ignore touches that are not its subviews")
    }

    func testSubview() {
        let stackView = newTouchesStackView()
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        stackView.addSubview(subview)
        let point = CGPoint(x: 20, y: 20)
        let touched = stackView.hitTest(point, with: nil)
        XCTAssertEqual(touched, subview, "The stack view should return the subview as the receiver")
    }

}
