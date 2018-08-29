//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import XCTest
import AVFoundation

final class CameraSegmentHandlerTests: XCTestCase {

    func testMerge() {
        let cameraSegmentHandler = CameraSegmentHandler()
        guard let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") else {
            XCTFail("no valid url found")
            return
        }
        cameraSegmentHandler.addNewVideoSegment(url: url)
        cameraSegmentHandler.addNewVideoSegment(url: url)
        cameraSegmentHandler.exportVideo(completion: { url in
            guard let url = url else {
                XCTFail("should have a valid url for video merging")
                return
            }
            let asset = AVURLAsset(url: url)
            let videoTracks = asset.tracks(withMediaType: .video)
            let audioTracks = asset.tracks(withMediaType: .audio)
            XCTAssert(videoTracks.count == 1, "There should be one video track")
            XCTAssert(audioTracks.count == 1, "There should be one audio track")
            
            if let videoTrack = videoTracks.first, let audioTrack = audioTracks.first {
                let videoDuration = videoTrack.timeRange.duration
                let audioDuration = audioTrack.timeRange.duration
                XCTAssert(CMTimeCompare(audioDuration, videoDuration) == 0, "Tracks were not synced")
            }
            else {
                XCTFail("Audio and video tracks not found")
            }
        })
    }

    func testAddImage() {
        let cameraSegmentHandler = CameraSegmentHandler()
        let images = createImagesArray()
        XCTAssert(images.count > 0, "Images should have been added")
        for image in images {
            cameraSegmentHandler.addNewImageSegment(image: image, size: image.size, completion: { (success, segment) in
                XCTAssert(success, "appending an image failed to create a CameraSegment")

                if cameraSegmentHandler.segments.count == images.count {
                    cameraSegmentHandler.exportVideo(completion: { url in
                        XCTAssert(url != nil, "should have a valid url for images merging")
                    })
                }
            })
        }
    }

    func testAddVideo() {
        let cameraSegmentHandler = CameraSegmentHandler()
        if let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            cameraSegmentHandler.addNewVideoSegment(url: url)
            XCTAssert(cameraSegmentHandler.segments.count == 1, "CameraSegmentHandler failed to add video segment")
        }
        else {
            XCTFail("url was not found for video")
        }
    }

    func testDeleteSegment() {
        let cameraSegmentHandler = CameraSegmentHandler()
        let images = createImagesArray()
        XCTAssert(images.count > 0, "Images should have been added")

        let deleteBlock: (() -> Void) = {
            cameraSegmentHandler.deleteSegment(index: 0, removeFromDisk: false)
        }

        for image in images {
            cameraSegmentHandler.addNewImageSegment(image: image, size: image.size, completion: { (success, segment) in
                XCTAssert(success, "appending an image failed to create a CameraSegment")

                if cameraSegmentHandler.segments.count == images.count {
                    deleteBlock()
                    XCTAssert(cameraSegmentHandler.segments.count == images.count - 1, "failed to delete a segment properly")
                }
            })
        }
    }
    
    func createImagesArray() -> [UIImage] {
        var images: [UIImage] = []

        if let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png"), let image = UIImage(contentsOfFile: path) {
            for _ in 0...5 {
                images.append(image)
            }
        }

        return images
    }
    
}
