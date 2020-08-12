//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import XCTest

@testable import KanvasCamera

class KanvasMediaPickerViewControllerTests: XCTestCase {
    func test() {
        let _ = KanvasMediaPickerViewController(settings: CameraSettings())
    }
}
