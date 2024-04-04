//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
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
