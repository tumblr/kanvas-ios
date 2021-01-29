//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import XCTest

final class GifVideoOutputHandlerTests: XCTestCase {

    func setupHandler() -> GifVideoOutputHandler {
        let handler = GifVideoOutputHandler(videoOutput: nil)
        return handler
    }

    func testBlockCompletion() {
        let handler = setupHandler()
        let blockExpectation = XCTestExpectation(description: "entered block")
        handler.takeGifMovie(assetWriter: nil, pixelBufferAdaptor: nil, videoInput: nil, audioInput: nil, numberOfFrames: 10, framesPerSecond: 10) { success in
            XCTAssert(success == false, "Should not have started gif without data output or asset writer")
            blockExpectation.fulfill()
        }
        wait(for: [blockExpectation], timeout: 5)
    }

}
