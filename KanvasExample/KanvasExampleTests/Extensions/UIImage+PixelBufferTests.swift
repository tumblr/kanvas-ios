//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest
import CoreMedia

final class UIImagePixelBufferTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    private func newView() -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }

    func testUIImageToPixelBufferToUIImage() {
        let view = newView()
        guard let uiImage = KanvasImages.filterTypes[.plasma] else {
            XCTFail("Failed to load test image")
            return
        }
        guard let pixelBuffer = uiImage?.pixelBuffer() else {
            XCTFail("Failed to create pixel buffer")
            return
        }
        let newUIImage = UIImage(pixelBuffer: pixelBuffer)
        let imageView = UIImageView(image: newUIImage)
        imageView.add(into: view)
        FBSnapshotVerifyView(view, tolerance: 0.05)
    }
}
