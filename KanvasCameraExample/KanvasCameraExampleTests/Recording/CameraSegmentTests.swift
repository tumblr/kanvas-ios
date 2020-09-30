//
// Created by Tony Cheng on 8/21/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import XCTest

final class CameraSegmentTests: XCTestCase {

    func testImageSegment() {
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            let segment = CameraSegment.image(image, nil, nil, mediaInfo)
            XCTAssert(segment.image != nil, "CameraSegment was not initialized properly")
        }
        else {
            XCTFail("sample image was not found")
        }
    }

    func testVideoSegment() {
        if let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            let segment = CameraSegment.video(url, mediaInfo)
            XCTAssert(segment.videoURL != nil, "CameraSegment was not initialized properly")
        }
        else {
            XCTFail("sample mp4 file was not found")
        }

    }

}
