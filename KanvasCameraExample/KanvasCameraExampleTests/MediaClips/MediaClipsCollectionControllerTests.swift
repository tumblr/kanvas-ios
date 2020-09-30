//
// Created by Tony Cheng on 8/21/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import UIKit
import XCTest

final class MediaClipsCollectionControllerTests: XCTestCase {

    func newViewController() -> MediaClipsCollectionController {
        let viewController = MediaClipsCollectionController()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        viewController.view.layoutIfNeeded()
        return viewController
    }

    func newMediaClip() -> MediaClip? {
        var mediaClip: MediaClip? = nil
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            mediaClip = MediaClip(representativeFrame: image, overlayText: "00:02", lastFrame: image)
        }
        return mediaClip
    }

    func testAddClips() {
        let viewController = newViewController()
        guard let mediaClip = newMediaClip() else {
            XCTFail("Media clip was not created")
            return
        }
        viewController.addNewClip(mediaClip)
        XCTAssert(viewController.getClips().count == 1, "Clip count \(viewController.getClips()) does not match expected after adding")
    }

}
