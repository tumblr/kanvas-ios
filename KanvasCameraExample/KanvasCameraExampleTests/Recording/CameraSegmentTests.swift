//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest
import Utils

final class CameraSegmentTests: XCTestCase {

    func testImageSegment() {
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            let mediaInfo = TumblrMediaInfo(source: .kanvas_camera)
            let segment = CameraSegment.image(image, nil, nil, mediaInfo)
            XCTAssert(segment.image != nil, "CameraSegment was not initialized properly")
        }
        else {
            XCTFail("sample image was not found")
        }
    }

    func testVideoSegment() {
        if let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let mediaInfo = TumblrMediaInfo(source: .kanvas_camera)
            let segment = CameraSegment.video(url, mediaInfo)
            XCTAssert(segment.videoURL != nil, "CameraSegment was not initialized properly")
        }
        else {
            XCTFail("sample mp4 file was not found")
        }

    }

}
