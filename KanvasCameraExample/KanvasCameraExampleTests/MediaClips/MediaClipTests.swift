//
// Created by Tony Cheng on 8/29/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class MediaClipTests: XCTestCase {

    func testMediaClipImage() {
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            let mediaClip = MediaClip(representativeFrame: image, overlayText: nil, lastFrame: image)
            XCTAssert(mediaClip.representativeFrame == image, "MediaClip's image was not initialized properly")
        }
        else {
            XCTFail("sample image was not found")
        }
    }

    func testMediaClipText() {
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            let mediaClip = MediaClip(representativeFrame: image, overlayText: "test", lastFrame: image)
            XCTAssert(mediaClip.overlayText == "test", "MediaClip's text was not initialized properly")
        }
        else {
            XCTFail("sample image was not found")
        }
    }

}
