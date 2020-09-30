//
// Created by Tony Cheng on 8/21/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class MediaClipsCollectionCellTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newCell() -> MediaClipsCollectionCell {
        let cell = MediaClipsCollectionCell(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: MediaClipsCollectionCell.width, height: MediaClipsCollectionCell.minimumHeight)))
        return cell
    }

    func testMediaClip() {
        let cell = newCell()
        var mediaClip: MediaClip? = nil
        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            mediaClip = MediaClip(representativeFrame: image, overlayText: "00:02", lastFrame: image)
        }
        guard let clip = mediaClip else {
            XCTFail("Image not found, media clip was not created")
            return
        }

        cell.bindTo(clip)
        FBSnapshotVerifyView(cell)
    }

}
