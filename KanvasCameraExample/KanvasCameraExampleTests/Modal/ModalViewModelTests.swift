//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class ModalViewModelTests: XCTestCase {

    func testSetUpOneOption() {
        var called = false
        let callback: () -> () = { called = true }
        let viewModel = ModalViewModel(text: "This is one very very loooong text for the modal alert", buttonTitle: "OK", buttonCallback: callback)
        XCTAssertNotNil(viewModel.confirmCallback)
        viewModel.confirmCallback()
        XCTAssert(called)
        XCTAssertNil(viewModel.cancelCallback)
        XCTAssertNil(viewModel.buttonsLayout)
    }

    func testSetUpTwoOptionsSideBySide() {
        var confirmCalled = false
        var cancelCalled = false
        let confirmCallback: () -> () = { confirmCalled = true }
        let cancelCallback: () -> () = { cancelCalled = true }
        let viewModel = ModalViewModel(text: "This is one short modal alert text",
                                       confirmTitle: "OK", confirmCallback: confirmCallback,
                                       cancelTitle: "CANCEL", cancelCallback: cancelCallback,
                                       buttonsLayout: .oneNextToTheOther)
        XCTAssertNotNil(viewModel.confirmCallback)
        XCTAssertNotNil(viewModel.cancelCallback)
        viewModel.confirmCallback()
        XCTAssert(confirmCalled)
        viewModel.cancelCallback?()
        XCTAssert(cancelCalled)
        XCTAssert(viewModel.buttonsLayout == .oneNextToTheOther)
    }

    func testSetUpTwoOptionsVertical() {
        var confirmCalled = false
        var cancelCalled = false
        let confirmCallback: () -> () = { confirmCalled = true }
        let cancelCallback: () -> () = { cancelCalled = true }
        let viewModel = ModalViewModel(text: "This is one very very loooong text for the modal alert",
                                       confirmTitle: "Long confirm title for button", confirmCallback: confirmCallback,
                                       cancelTitle: "Short CANCEL", cancelCallback: cancelCallback,
                                       buttonsLayout: .oneBelowTheOther)
        XCTAssertNotNil(viewModel.confirmCallback)
        XCTAssertNotNil(viewModel.cancelCallback)
        viewModel.confirmCallback()
        XCTAssert(confirmCalled)
        viewModel.cancelCallback?()
        XCTAssert(cancelCalled)
        XCTAssert(viewModel.buttonsLayout == .oneBelowTheOther)
    }

}
