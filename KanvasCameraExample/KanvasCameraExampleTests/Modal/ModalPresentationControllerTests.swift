//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class ModalPresentationControllerTests: XCTestCase {

    func newPresentingController() -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .red
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return controller
    }

    func newPresentedController() -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .blue
        return controller
    }

    func newController(presented: UIViewController, presenting: UIViewController) -> ModalPresentationController {
        let controller = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        return controller
    }

    func testZeroFrameWhenNoContainerView() {
        let presenting = newPresentingController()
        let presented = newPresentedController()
        let presentation = newController(presented: presented, presenting: presenting)
        XCTAssertEqual(presentation.frameOfPresentedViewInContainerView, CGRect.zero)
    }

}
