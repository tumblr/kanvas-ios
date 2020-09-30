//
// Created by Tony Cheng on 8/27/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
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
