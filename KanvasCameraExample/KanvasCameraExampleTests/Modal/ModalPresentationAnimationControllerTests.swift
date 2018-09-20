//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class ModalPresentationAnimationControllerTests: XCTestCase {

    func newPresentingController() -> ModalPresentationAnimationController {
        let controller = ModalPresentationAnimationController(isPresenting: true)
        return controller
    }

    func newDismissingController() -> ModalPresentationAnimationController {
        let controller = ModalPresentationAnimationController(isPresenting: false)
        return controller
    }

    func testDurationWhenPresenting() {
        let controller = newPresentingController()
        XCTAssertEqual(controller.transitionDuration(using: nil), 0.5)
    }

    func testDurationWhenDismissing() {
        let controller = newDismissingController()
        XCTAssertEqual(controller.transitionDuration(using: nil), 0.5)
    }

}
