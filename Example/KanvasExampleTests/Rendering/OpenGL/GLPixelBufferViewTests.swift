//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
import XCTest

class GLPixelBufferViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPixelBufferView() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let view = GLPixelBufferView(delegate: nil)
        view.frame = rect
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }) {
            if let pixelBuffer = image.pixelBuffer() {
                view.displayPixelBuffer(pixelBuffer)
            }
            else {
                XCTAssert(false, "Failed to generate pixel buffer")
            }
            _ = view
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 2.0))
            FBSnapshotArchFriendlyVerifyView(view)
        }
        else {
            XCTAssert(false, "Failed to load sample.png")
        }
    }

}
