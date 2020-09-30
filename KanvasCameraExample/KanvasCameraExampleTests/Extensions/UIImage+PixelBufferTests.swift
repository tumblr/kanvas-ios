//
//  UIImage+PixelBufferTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 3/7/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
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
        guard let uiImage = KanvasCameraImages.filterTypes[.plasma] else {
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
        FBSnapshotVerifyView(view)
    }
}
