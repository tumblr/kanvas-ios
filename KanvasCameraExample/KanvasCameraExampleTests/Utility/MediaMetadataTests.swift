//
//  MediaMetadataTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 4/29/19.
//  Copyright © 2019 Tumblr. All rights reserved.
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
            guard let url = CameraController.save(image: image, info: .init(source: .kanvas_camera)) else {
                XCTFail()
                return
            }
            let mediaInfo = MediaInfo(fromImage: url)
            XCTAssertEqual(mediaInfo?.source, .kanvas_camera)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

}
