//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
@testable import KanvasCamera

final class VideoOutputHandlerTests: XCTestCase {

    func setupHandler() -> VideoOutputHandler {
        let handler = VideoOutputHandler()
        return handler
    }

    func testStartRecording() {
        let handler = setupHandler()
        handler.startRecordingVideo(assetWriter: nil, pixelBufferAdaptor: nil, videoInput: nil, audioInput: nil)
        XCTAssert(handler.recording == false, "Handler should not have started recording without an asset writer")
    }

    func testFinishRecordingBlock() {
        let handler = setupHandler()
        let expectation = XCTestExpectation(description: "finished recording expectation")
        handler.stopRecordingVideo { success in
            XCTAssert(success == false, "Should not have finished recording without ever starting recording")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
