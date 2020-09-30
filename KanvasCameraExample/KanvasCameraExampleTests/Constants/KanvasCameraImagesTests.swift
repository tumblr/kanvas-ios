//
// Created by Tony Cheng on 8/16/18.
// Copyright (c) 2018 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import XCTest

final class KanvasCameraImagesTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        
        recordMode = false
    }
    
    func testPhotoModeImage() {
        let imageView = newImageView()
        let image = KanvasCameraImages.photoModeImage
        /// photo image can be nil.
        imageView.image = image
        FBSnapshotVerifyView(imageView)
    }

    func testStopMotionModeImage() {
        let imageView = newImageView()
        let image = KanvasCameraImages.stopMotionModeImage
        /// stop motion image can be nil.
        imageView.image = image
        FBSnapshotVerifyView(imageView)
    }

    func testFlashOnImage() {
        let imageView = newImageView()
        let image = KanvasCameraImages.flashOnImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotVerifyView(imageView)
    }

    func testFlashOffImage() {
        let imageView = newImageView()
        let image = KanvasCameraImages.flashOffImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotVerifyView(imageView)
    }

    func testCameraPositionImage() {
        let imageView = newImageView()
        let image = KanvasCameraImages.cameraPositionImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotVerifyView(imageView)
    }

    func testCloseImage() {
        let imageView = newImageView()
        let image = KanvasCameraImages.closeImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotVerifyView(imageView)
    }

    func testConfirmImage() {
        let imageView = newImageView()
        let image = KanvasCameraImages.confirmImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotVerifyView(imageView)
    }

    func testBackImage() {
        let imageView = newImageView()
        let image = KanvasCameraImages.backImage
        XCTAssert(image != nil, "Image not found")
        imageView.image = image
        FBSnapshotVerifyView(imageView)
    }

    func newImageView() -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
