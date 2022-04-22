//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import FBSnapshotTestCase
import Foundation
import XCTest

final class KanvasImagesTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        
        recordMode = false
    }
    
    func testPhotoModeImage() {
        let imageView = newImageView()
        let image = KanvasImages.photoModeImage
        /// photo image can be nil.
        imageView.image = image
        FBSnapshotArchFriendlyVerifyView(imageView)
    }

    func testStopMotionModeImage() {
        let imageView = newImageView()
        let image = KanvasImages.stopMotionModeImage
        /// stop motion image can be nil.
        imageView.image = image
        FBSnapshotArchFriendlyVerifyView(imageView)
    }

    func testFlashOnImage() {
        let imageView = newImageView()
        let image = KanvasImages.flashOnImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotArchFriendlyVerifyView(imageView)
    }

    func testFlashOffImage() {
        let imageView = newImageView()
        let image = KanvasImages.flashOffImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotArchFriendlyVerifyView(imageView)
    }

    func testCameraPositionImage() {
        let imageView = newImageView()
        let image = KanvasImages.cameraPositionImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotArchFriendlyVerifyView(imageView)
    }

    func testCloseImage() {
        let imageView = newImageView()
        let image = KanvasImages.closeImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotArchFriendlyVerifyView(imageView)
    }

    func testConfirmImage() {
        let imageView = newImageView()
        let image = KanvasImages.shared.confirmImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotArchFriendlyVerifyView(imageView)
    }

    func testBackImage() {
        let imageView = newImageView()
        let image = KanvasImages.backImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotArchFriendlyVerifyView(imageView)
    }

    func newImageView() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
