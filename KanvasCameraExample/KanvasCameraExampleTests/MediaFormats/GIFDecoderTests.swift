//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import XCTest

final class GIFDecoderTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        // This is a snapshot test to make it easy to extract frames from a GIF
        // for making the test itself. If you work on the decoder, and this test
        // fails, don't just regenerate the snapshots to make it pass - you broke
        // the decoder! Please, investigate why this test failed :)
        self.recordMode = false
    }

    func testDecodeGIF() {
        guard let gifURL = Bundle(for: type(of: self)).url(forResource: "colors", withExtension: "gif") else {
            XCTFail("Could not load colors.gif")
            return
        }
        let view = UIImageView()
        let expectedInterval = 0.15
        GIFDecoderFactory.create(type: .imageIO).decode(image: gifURL) { frames in
            XCTAssertTrue(frames.count == 13)
            for (i, frame) in frames.enumerated() {
                XCTAssertEqual(frame.interval, expectedInterval)
                view.frame = CGRect(x: 0, y: 0, width: frame.image.width, height: frame.image.height)
                view.image = UIImage(cgImage: frame.image)
                view.layoutIfNeeded()
                self.FBSnapshotVerifyView(view, identifier: "\(i)")
            }
        }

    }
}
