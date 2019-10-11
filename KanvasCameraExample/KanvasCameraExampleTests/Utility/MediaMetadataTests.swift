//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

@testable import KanvasCamera

class MediaMetadataTests: XCTestCase {

    func testWriteAndReadMetadataWithVideo() {
        let expectation = XCTestExpectation(description: "testWriteAndReadMetadataWithVideo")
        let mode = CameraMode.stopMotion
        let segmentsHandler = CameraSegmentHandler()
        let settings = CameraSettings()
        let recorder = CameraRecorderStub(size: CGSize(width: 300, height: 300), photoOutput: nil, videoOutput: nil, audioOutput: nil, recordingDelegate: nil, segmentsHandler: segmentsHandler, settings: settings)
        recorder.startRecordingVideo(on: mode)
        recorder.stopRecordingVideo() { _ in
            recorder.exportRecording(completion: { url in
                guard let url = url else {
                    XCTFail()
                    return
                }
                let mediaInfo = KanvasMediaMetadata.readMediaInfo(fromVideo: url)
                XCTAssertEqual(mediaInfo?.source, .kanvas_camera)
                expectation.fulfill()
            })
        }
        wait(for: [expectation], timeout: 5)
    }

    func testWriteAndReadMetadataWithImage() {
        let expectation = XCTestExpectation(description: "testWriteAndReadMetadataWithImage")
        let settings = CameraSettings()
        let segmentsHandler = CameraSegmentHandler()
        let recorder = CameraRecorderStub(size: CGSize(width: 300, height: 300), photoOutput: nil, videoOutput: nil, audioOutput: nil, recordingDelegate: nil, segmentsHandler: segmentsHandler, settings: settings)
        recorder.takePhoto(on: .photo) { image in
            guard let url = CameraController.saveImageToFile(image, info: .init(source: .kanvas_camera)) else {
                XCTFail()
                return
            }
            let mediaInfo = try? KanvasMediaMetadata.readMediaInfo(fromImage: url)
            XCTAssertEqual(mediaInfo??.source, .kanvas_camera)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

}
