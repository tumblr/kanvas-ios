//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class IgnoreTouchesViewTests: XCTestCase {

    func newTouchesView() -> IgnoreTouchesView {
        let view = IgnoreTouchesView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        return view
    }

    func testTouchInBounds() {
        let view = newTouchesView()
        let point = CGPoint(x: 20, y: 20)
        let touched = view.hitTest(point, with: nil)
        XCTAssert(touched == nil, "The view should ignore touches that are not its subviews")
    }

    func testSubview() {
        let view = newTouchesView()
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.addSubview(subview)
        let point = CGPoint(x: 20, y: 20)
        let touched = view.hitTest(point, with: nil)
        XCTAssert(touched == subview, "The view should return the subview as the receiver")

    }

}
