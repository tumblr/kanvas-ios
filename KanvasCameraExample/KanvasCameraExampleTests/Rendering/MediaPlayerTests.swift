//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
import AVFoundation
import GLKit

@testable import KanvasCamera

class MediaPlayerTests: XCTestCase {

    class RendererMock: Rendering {

        var backgroundFillColor: CGColor = UIColor.clear.cgColor

        var mediaTransform: GLKMatrix4?

        var outputDimensions: CGSize = .zero

        var switchInputDimensions: Bool = false

        var startTime: TimeInterval?

        weak var delegate: RendererDelegate?

        var filterType: FilterType = .passthrough
        var imageOverlays: [CGImage] = []

        var processedSampleBufferCallCount: UInt = 0
        var processedSampleBuffer: CMSampleBuffer?

        func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, time: TimeInterval) {
            processedSampleBufferCallCount += 1
            processedSampleBuffer = sampleBuffer
        }

        func output(filteredPixelBuffer: CVPixelBuffer) {

        }

        func processSingleImagePixelBuffer(_ pixelBuffer: CVPixelBuffer, time: TimeInterval) -> CVPixelBuffer? {
            return pixelBuffer
        }

        func refreshFilter() {
        }

        func reset() {

        }
    }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPlayImage() {
        guard let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }) else {
            XCTFail("Could not load sample.png")
            return
        }
        let renderer = mockRenderer()
        let player = MediaPlayer(renderer: renderer)
        player.play(media: [.image(image)])
        XCTAssertEqual(renderer.processedSampleBufferCallCount, 2, "Expected processSampleBuffer to be called twice")
        XCTAssertNotNil(renderer.processedSampleBuffer, "Expected processSampleBuffer to be called")
    }

    func testPlayVideo() {
        guard let videoURL = Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4") else {
            XCTFail("Could not load sample.mp4")
            return
        }

        let asset = AVAsset(url: videoURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            XCTFail("Could not find a video track")
            return
        }
        let frameRate = videoTrack.nominalFrameRate

        let renderer = mockRenderer()
        let player = MediaPlayer(renderer: renderer)
        player.play(media: [.video(videoURL)])

        // Let the video play for one second
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

        // After a second, processedSampleBuffer should have been called for each frame of video.
        // Using greater-than since we'll most likely be called faster than the framerate.
        // Also, always checking processedSampleBufferCallCount - 1 since the first call is initialization.
        // AAAlso, compare against frameRate - 10, since the tests could be slow...
        print(renderer.processedSampleBufferCallCount - 1, UInt(frameRate))
        XCTAssertGreaterThan(renderer.processedSampleBufferCallCount - 1, UInt(frameRate - 10), "Expected processSampleBuffer to be called for approximately each frame of video")
        XCTAssertNotNil(renderer.processedSampleBuffer, "Expected processSampleBuffer to be called")
    }

    func mockRenderer() -> RendererMock {
        return RendererMock()
    }

}
