//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

@testable import Kanvas
class MediaMetadataTests: XCTestCase {

    func testWriteAndReadMetadataWithVideo() {
        let expectation = XCTestExpectation(description: "testWriteAndReadMetadataWithVideo")
        let mode = CameraMode.stopMotion
        let segmentsHandler = CameraSegmentHandler()
        let settings = CameraSettings()
        let recorder = CameraRecorderStub(size: CGSize(width: 300, height: 300), photoOutput: nil, videoOutput: nil, audioOutput: nil, recordingDelegate: nil, segmentsHandler: segmentsHandler, settings: settings)
        recorder.startRecordingVideo(on: mode)
        recorder.stopRecordingVideo() { _ in
            recorder.exportRecording(completion: { (url, mediaInfo) in
                guard url != nil else {
                    XCTFail()
                    return
                }
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
            let info = MediaInfo(source: .kanvas_camera)
            guard let data = image?.jpegData(compressionQuality: 1),
                  let url = try? CameraController.save(data: data, to: "kanvas-image", ext: "jpg") else {
                XCTFail()
                return
            }
            info.write(toImage: url)
            let mediaInfo = MediaInfo(fromImage: url)
            XCTAssertEqual(mediaInfo?.source, .kanvas_camera)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

}
