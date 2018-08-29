//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
@testable import KanvasCamera

final class CameraSegmentTests: XCTestCase {

    func testImageSegment() {
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            let segment = CameraSegment.image(image, nil)
            XCTAssert(segment.image != nil, "CameraSegment was not initialized properly")
        }
        else {
            XCTFail("sample image was not found")
        }
    }

    func testVideoSegment() {
        if let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let segment = CameraSegment.video(url)
            XCTAssert(segment.videoURL != nil, "CameraSegment was not initialized properly")
        }
        else {
            XCTFail("sample mp4 file was not found")
        }

    }

}
