//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ImagePreviewControllerTests: FBSnapshotTestCase {
    
    private let testImage = KanvasCameraImages.confirmImage
    private let secondTestImage = KanvasCameraImages.flashOnImage
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func testPreviewWithNoImage() {
        let controller = ImagePreviewController()
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testSetImagePreview() {
        let controller = ImagePreviewController()
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(true)
        controller.setImagePreview(testImage)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testSetImagePreviewWithNil() {
        let controller = ImagePreviewController()
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(true)
        controller.setImagePreview(nil)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testSetImagePreviewOff() {
        let controller = ImagePreviewController()
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(false)
        controller.setImagePreview(testImage)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
    
    func testSetImagePreviewTwice() {
        let controller = ImagePreviewController()
        UIView.setAnimationsEnabled(false)
        controller.showImagePreview(true)
        controller.setImagePreview(testImage)
        controller.setImagePreview(secondTestImage)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
}
