//
//  MediaPickerButtonViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 6/24/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

import Foundation
import XCTest
import FBSnapshotTestCase
@testable import KanvasCamera

final class MediaPickerButtonViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func testButtonEnabled() {
        let settings = CameraSettings()
        settings.features.mediaPicking = true
        let view = MediaPickerButtonView(settings: settings)
        view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }) {
            view.setThumbnail(image)
        }
        FBSnapshotVerifyView(view)
    }

    func testButtonDisabled() {
        let settings = CameraSettings()
        settings.features.mediaPicking = false
        let view = MediaPickerButtonView(settings: settings)
        view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }) {
            view.setThumbnail(image)
        }
        FBSnapshotVerifyView(view)
    }

}
