//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class CameraSettingsTests: XCTestCase {
    
    // test that the defaults have not changed unexpectedly
    func testDefaultSettings() {
        let settings = CameraSettings()
        
        XCTAssert(settings.enabledModes == [.photo, .gif, .stopMotion], "Expected default settings for camera modes to be enabled.")
    }
    
}
