//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import XCTest

final class GIFEncoderTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    private func image(color: UIColor, size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(.init(origin: .zero, size: size))
        }
    }

    private func videoFromColors(colors: [UIColor], size: CGSize, interval: TimeInterval, completion: @escaping (URL?) -> Void) {
        let images = colors.map{ image(color: $0, size: size) }
        let segments = images.map{ CameraSegment.image($0, nil, interval, .init(source: .kanvas_camera)) }
        CameraSegmentHandler().mergeAssets(segments: segments) { (url, info) in
            completion(url)
        }
    }

    func testEncodeGIF() {

        ///
        /// Arrange
        ///

        let expectation = XCTestExpectation(description: "GIF encode test")

        let colors: [UIColor] = [.red, .green]
        let videoFrameDelay = 1.0
        let gifFramesPerSecond = 10
        let loopCount = 0
        videoFromColors(colors: colors, size: .init(width: 100, height: 100), interval: videoFrameDelay) { url in

            XCTAssertNotNil(url)
            guard let url = url else {
                expectation.fulfill()
                return
            }

            ///
            /// Act
            ///

            GIFEncoderImageIO().encode(video: url, loopCount: loopCount, framesPerSecond: gifFramesPerSecond) { gifURL in

                ///
                /// Assert
                ///

                XCTAssertNotNil(gifURL)
                guard let gifURL = gifURL else {
                    expectation.fulfill()
                    return
                }

                let someSource = CGImageSourceCreateWithURL(gifURL as CFURL, nil)
                XCTAssertNotNil(someSource)
                guard let source = someSource else {
                    expectation.fulfill()
                    return
                }

                let expectedFrameCount = Int(videoFrameDelay * Double(gifFramesPerSecond) * Double(colors.count))
                let actualFrameCount = CGImageSourceGetCount(source)
                XCTAssertEqual(expectedFrameCount, actualFrameCount)

                let someFirstCGImage = CGImageSourceCreateImageAtIndex(source, 0 + Int(Double(gifFramesPerSecond) / 2.0), nil)
                XCTAssertNotNil(someFirstCGImage)
                guard let firstCGImage = someFirstCGImage else {
                    expectation.fulfill()
                    return
                }

                let view = UIImageView()
                let image = UIImage(cgImage: firstCGImage)
                view.frame = CGRect(origin: .zero, size: image.size)
                view.image = image
                self.FBSnapshotVerifyView(view, identifier: "first")

                let someLastCGImage = CGImageSourceCreateImageAtIndex(source, actualFrameCount - Int(Double(gifFramesPerSecond) / 2.0), nil)
                XCTAssertNotNil(someLastCGImage)
                guard let lastCGImage = someLastCGImage else {
                    expectation.fulfill()
                    return
                }

                let view1 = UIImageView()
                let image1 = UIImage(cgImage: lastCGImage)
                view1.frame = CGRect(origin: .zero, size: image1.size)
                view1.image = image1
                self.FBSnapshotVerifyView(view1, identifier: "last")

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

}
