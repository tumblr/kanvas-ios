//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
import FBSnapshotTestCase

@testable import KanvasCamera

class GLPlayerViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        recordMode = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPlayImage() {
        guard let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }) else {
            XCTFail("Could not load sample.png")
            return
        }
        let player = GLPlayer(renderer: GLRenderer())
        let view = GLPlayerView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        player.playerView = view
        player.play(media: [
            GLPlayerMedia.image(image)
        ])
        RunLoop.main.run(until: Date.init(timeIntervalSinceNow: 2))
        FBSnapshotVerifyView(view)
    }

}
