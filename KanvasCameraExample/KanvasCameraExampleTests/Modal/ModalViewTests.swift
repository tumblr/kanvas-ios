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

final class ModalViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newView(layout: ModalButtonsLayout) -> ModalView {
        let view = ModalView(buttonsLayout: layout)
        view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        return view
    }

    func testSetUpOneOptionNextLayout() {
        let viewModel = ModalViewModel(text: "This is one very very loooong text for the modal alert", buttonTitle: "OK") {}
        let view = newView(layout: .oneNextToTheOther)
        view.configureModal(viewModel)
        FBSnapshotVerifyView(view)
    }

    func testSetUpOneOptionBelowLayout() {
        let viewModel = ModalViewModel(text: "This is one very very loooong text for the modal alert", buttonTitle: "OK") {}
        let view = newView(layout: .oneBelowTheOther)
        view.configureModal(viewModel)
        FBSnapshotVerifyView(view)
    }

    func testSetUpTwoOptionsSideBySide() {
        let viewModel = ModalViewModel(text: "This is one short modal alert text",
                                       confirmTitle: "OK", confirmCallback: {},
                                       cancelTitle: "CANCEL", cancelCallback: {},
                                       buttonsLayout: .oneNextToTheOther)
        let view = newView(layout: .oneNextToTheOther)
        view.configureModal(viewModel)
        FBSnapshotVerifyView(view)
    }

    func testSetUpTwoOptionsVertical() {
        let viewModel = ModalViewModel(text: "This is one very very loooong text for the modal alert",
                                       confirmTitle: "Long confirm title for button", confirmCallback: {},
                                       cancelTitle: "Short CANCEL", cancelCallback: {},
                                       buttonsLayout: .oneBelowTheOther)
        let view = newView(layout: .oneBelowTheOther)
        view.configureModal(viewModel)
        FBSnapshotVerifyView(view)
    }

}
