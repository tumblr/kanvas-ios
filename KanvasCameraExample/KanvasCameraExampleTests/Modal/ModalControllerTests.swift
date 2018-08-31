//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest
import FBSnapshotTestCase

final class ModalControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newViewController(viewModel: ModalViewModel) -> ModalController {
        let viewController = ModalController(viewModel: viewModel)
        viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return viewController
    }

    func testSetUpOneOption() {
        let viewModel = ModalViewModel(text: "This is one very very loooong text for the modal alert", buttonTitle: "OK") {}
        let viewController = newViewController(viewModel: viewModel)
        FBSnapshotVerifyView(viewController.view)
    }

    func testSetUpTwoOptionsSideBySide() {
        let viewModel = ModalViewModel(text: "This is one short modal alert text",
                                       confirmTitle: "OK", confirmCallback: {},
                                       cancelTitle: "CANCEL", cancelCallback: {},
                                       buttonsLayout: .oneNextToTheOther)
        let viewController = newViewController(viewModel: viewModel)
        FBSnapshotVerifyView(viewController.view)
    }

    func testSetUpTwoOptionsVertical() {
        let viewModel = ModalViewModel(text: "This is one very very loooong text for the modal alert",
                                       confirmTitle: "Long confirm title for button", confirmCallback: {},
                                       cancelTitle: "Short CANCEL", cancelCallback: {},
                                       buttonsLayout: .oneBelowTheOther)
        let viewController = newViewController(viewModel: viewModel)
        FBSnapshotVerifyView(viewController.view)
    }

}
