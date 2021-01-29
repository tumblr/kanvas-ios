//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import AVFoundation
import Foundation
import XCTest

final class CameraSegmentHandlerTests: XCTestCase {
    
    func testMerge() {
        let cameraSegmentHandler = CameraSegmentHandler()
        guard let url = createVideo() else {
            XCTFail("no valid url found")
            return
        }
        let mediaInfo = MediaInfo(source: .media_library)
        cameraSegmentHandler.addNewVideoSegment(url: url, mediaInfo: mediaInfo)
        cameraSegmentHandler.addNewVideoSegment(url: url, mediaInfo: mediaInfo)
        let expectation = XCTestExpectation(description: "merged")
        cameraSegmentHandler.exportVideo(completion: { url, mediaInfoOutput in
            guard let url = url else {
                XCTFail("should have a valid url for video merging")
                return
            }
            let asset = AVURLAsset(url: url)
            let videoTracks = asset.tracks(withMediaType: .video)
            let audioTracks = asset.tracks(withMediaType: .audio)
            XCTAssert(videoTracks.count == 1, "There should be one video track")
            XCTAssert(audioTracks.count == 1, "There should be one audio track")
            XCTAssertEqual(mediaInfoOutput?.source, .kanvas_camera)
            expectation.fulfill()
        })
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssert(result == .completed, "Merging did not complete")
    }
    
    func testAddImage() {
        let cameraSegmentHandler = CameraSegmentHandler()
        let images = createImagesArray()
        XCTAssert(images.count > 0, "Images should have been added")
        let mediaInfo = MediaInfo(source: .kanvas_camera)
        for image in images {
            cameraSegmentHandler.addNewImageSegment(image: image, size: image.size, mediaInfo: mediaInfo, completion: { (success, segment) in
                XCTAssert(success, "appending an image failed to create a CameraSegment")
                
                if cameraSegmentHandler.segments.count == images.count {
                    cameraSegmentHandler.exportVideo(completion: { url, mediaInfo in
                        XCTAssertEqual(mediaInfo?.source, .kanvas_camera, "should have the same media info as the original image")
                    })
                }
            })
        }
    }
    
    func testAddVideo() {
        let cameraSegmentHandler = CameraSegmentHandler()
        if let url = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") {
            let mediaInfo = MediaInfo(source: .kanvas_camera)
            cameraSegmentHandler.addNewVideoSegment(url: url, mediaInfo: mediaInfo)
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
            cameraSegmentHandler.deleteSegment(at: 0, removeFromDisk: false)
        }
        let mediaInfo = MediaInfo(source: .kanvas_camera)
        for image in images {
            cameraSegmentHandler.addNewImageSegment(image: image, size: image.size, mediaInfo: mediaInfo, completion: { (success, segment) in
                XCTAssert(success, "appending an image failed to create a CameraSegment")
                
                if cameraSegmentHandler.segments.count == images.count {
                    deleteBlock()
                    XCTAssert(cameraSegmentHandler.segments.count == images.count - 1, "failed to delete a segment properly")
                }
            })
        }
    }
    
    func testMoveSegment() {
        let cameraSegmentHandler = CameraSegmentHandler()
        guard let image = createImage() else { XCTFail("no valid image found"); return }
        guard let url = createVideo() else { XCTFail("no valid url found"); return }
        
        let expectation = XCTestExpectation(description: "added image")
        let mediaInfo = MediaInfo(source: .kanvas_camera)
        cameraSegmentHandler.addNewImageSegment(image: image, size: image.size, mediaInfo: mediaInfo, completion: { (success, segment) in
            XCTAssert(success, "appending an image failed to create a CameraSegment")
            cameraSegmentHandler.addNewVideoSegment(url: url, mediaInfo: mediaInfo)
            cameraSegmentHandler.moveSegment(from: 1, to: 0)
            XCTAssertNotNil(cameraSegmentHandler.segments[0].videoURL)
            XCTAssertNil(cameraSegmentHandler.segments[0].image)
            XCTAssertNotNil(cameraSegmentHandler.segments[1].image)
            XCTAssertNil(cameraSegmentHandler.segments[1].videoURL)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 5.0)
    }
    
    func createImage() -> UIImage? {
        let path = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png")
        return path.flatMap { UIImage(contentsOfFile: $0) }
    }
    
    func createImagesArray() -> [UIImage] {
        var images: [UIImage] = []
        
        if let image = createImage() {
            for _ in 0...5 {
                images.append(image)
            }
        }
        
        return images
    }
    
    func createVideo() -> URL? {
        return Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4")
    }
}
