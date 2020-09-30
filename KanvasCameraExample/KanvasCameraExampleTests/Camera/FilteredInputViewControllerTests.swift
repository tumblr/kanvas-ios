//
//  FilteredInputViewControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 2/20/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import AVFoundation

class FilteredInputViewControllerDelegateStub: FilteredInputViewControllerDelegate {
    func filteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {

    }
}

final class FilteredInputViewControllerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFilteredInputView() {
        let delegate = FilteredInputViewControllerDelegateStub()
        let settings = CameraSettings()
        let controller = FilteredInputViewController(delegate: delegate, settings: settings)
        FBSnapshotVerifyView(controller.view)
    }

}
