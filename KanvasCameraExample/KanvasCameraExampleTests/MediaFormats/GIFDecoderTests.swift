//
//  GIFDecoderTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 5/4/20.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import XCTest

final class GIFDecoderTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        // This is a snapshot test to make it easy to extract frames from a GIF
        // for making the test itself. If you work on the decoder, and this test
        // fails, don't just regenerate the snapshots to make it pass - you broke
        // the decoder! Please, investigate why this test failed :)
        self.recordMode = false
    }

    func testDecodeGIF() {

        ///
        /// Arrange
        ///

        guard let gifURL = Bundle(for: type(of: self)).url(forResource: "colors", withExtension: "gif") else {
            XCTFail("Could not load colors.gif")
            return
        }

        // These are the frame delays in colors.gif.
        // Yes, they're all the same, but since GIF delays are per-frame,
        // just list each frame's delay.
        let expectedIntervals = [
            0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15
        ]
        let expectedFramesCount = expectedIntervals.count

        ///
        /// Act
        ///

        guard let decoder = GIFDecoderFactory.create(type: .imageIO) as? GIFDecoderImageIO else {
            XCTFail("Expected decoder to be of type GIFDecoderImageIO")
            return
        }

        // Doing this to directly test GIFDecoderImageIO so our testing tools
        // know GIFDecoderImageIO is being tested.
        let decode = GIFDecoderImageIO.decode(decoder)
        decode(gifURL) { frames in

            ///
            /// Assert
            ///

            XCTAssertEqual(frames.count, expectedFramesCount)

            let view = UIImageView()
            for (i, (frame, expectedInterval)) in zip(frames, expectedIntervals).enumerated() {
                XCTAssertEqual(frame.interval, expectedInterval)
                view.frame = CGRect(x: 0, y: 0, width: frame.image.width, height: frame.image.height)
                view.image = UIImage(cgImage: frame.image)
                view.layoutIfNeeded()
                self.FBSnapshotVerifyView(view, identifier: "\(i)")
            }
        }
    }

}
