//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
import AVFoundation
@testable import KanvasCamera

final class VideoOutputHandlerTests: XCTestCase {

    func setupHandler() -> VideoOutputHandler {
        let handler = VideoOutputHandler()
        return handler
    }
    
    func setupAssetWriter() -> AVAssetWriter? {
        do {
            guard let url = NSURL.createNewVideoURL() else {
                return nil
            }
            let assetWriter = try AVAssetWriter(outputURL: url, fileType: .mp4)
            return assetWriter
        }
        catch {
            return nil
        }
    }

    func testStartRecording() {
        let handler = setupHandler()
        guard let assetWriter = setupAssetWriter() else {
            XCTFail("failed to create asset writer")
            return
        }
        handler.startRecordingVideo(assetWriter: assetWriter, pixelBufferAdaptor: nil, videoInput: nil, audioInput: nil)
        XCTAssert(handler.recording == true, "Asset writer should have started recording")
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
