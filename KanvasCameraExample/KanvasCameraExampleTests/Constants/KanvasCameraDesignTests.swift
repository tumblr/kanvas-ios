//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class KanvasCameraDesignTests: XCTestCase {

    func testDefaultDesign() {
        XCTAssertFalse(KanvasCameraDesign.cameraDimensions.isRedesign, "The result should be false.")
    }
    
    func testRedesign() {
        XCTAssertTrue(KanvasCameraDesign.cameraRedesignDimensions.isRedesign, "The result should be true.")
    }

}
