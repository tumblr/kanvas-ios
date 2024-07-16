//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
import Foundation
import UIKit
import XCTest

final class FilterItemTests: XCTestCase {
    
    func testFilterColor() {
        let filterType = FilterType.plasma
        let filter = FilterItem(type: .plasma)
        XCTAssertEqual(filter.type, filterType, "Filter type does not match")
    }
}
