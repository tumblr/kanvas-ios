//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class DrawerTabBarOptionTests: XCTestCase {
    
    func testOptionDescription() {
        let option = DrawerTabBarOption.stickers
        XCTAssertEqual(option.description, "Stickers", "Option description does not match")
    }
}
