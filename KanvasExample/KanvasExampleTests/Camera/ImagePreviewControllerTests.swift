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

final class ImagePreviewControllerTests: FBSnapshotTestCase {
    
    private let testImage = KanvasImages.shared.confirmImage
    private let secondTestImage = KanvasImages.flashOnImage
    private var controller = ImagePreviewController()
    
    override func setUp() {
        super.setUp()

        recordMode = false

        controller = ImagePreviewController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
    }
    
    func testPreviewWithNoImage() {
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testSetImagePreview() {
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(true)
        controller.setImagePreview(testImage)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testSetImagePreviewWithNil() {
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(true)
        controller.setImagePreview(nil)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testSetImagePreviewOff() {
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(false)
        controller.setImagePreview(testImage)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testSetImagePreviewTwice() {
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(true)
        controller.setImagePreview(testImage)
        controller.setImagePreview(secondTestImage)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
}
