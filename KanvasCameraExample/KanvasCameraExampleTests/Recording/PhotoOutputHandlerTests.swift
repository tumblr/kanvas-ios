//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
import AVFoundation
@testable import KanvasCamera

final class PhotoOutputHandlerTests: XCTestCase {

    func setupHandler() -> PhotoOutputHandler {
        let handler = PhotoOutputHandler(photoOutput: nil)
        return handler
    }

    func testCompletionBlock() {
        let handler = setupHandler()
        let blockExpectation = XCTestExpectation(description: "block completed")
        handler.takePhoto(settings: AVCapturePhotoSettings()) { image in
            XCTAssert(image == nil, "Image should be nil if no photo output was passed")
            blockExpectation.fulfill()
        }
        wait(for: [blockExpectation], timeout: 5)
    }

}
