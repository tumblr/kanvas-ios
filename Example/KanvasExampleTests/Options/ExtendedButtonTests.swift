//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import UIKit
import XCTest

final class ExtendedButtonTests: XCTestCase {
    
    func testTouchOutsideOfButton() {
        let stackView = ExtendedButton(inset: -10)
        stackView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        view.addSubview(stackView)
        let touchPoint = CGPoint(x: 5, y: 5)
        let touched = stackView.point(inside: touchPoint, with: nil)
        XCTAssertTrue(touched, "Stack view did not receive touch")
    }
    
}
