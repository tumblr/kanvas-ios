//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest
import CoreMedia

final class GifMakerHandlerTests: XCTestCase {

    func testGifMakerHandler() {
        let handler = GifMakerHandler(player: MediaPlayer(renderer: nil), analyticsProvider: nil)
        XCTAssert(type(of: handler) == GifMakerHandler.self)
    }

    private func image(color: UIColor, size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(.init(origin: .zero, size: size))
        }
    }

    func testGetThumbnail() {

        //
        // Arrange
        //

        let e = expectation(description: "load segments")
        e.expectedFulfillmentCount = 1
        let player = MediaPlayer(renderer: nil)
        let handler = GifMakerHandler(player: player, analyticsProvider: nil)
        let colors: [UIColor] = [.red,  .orange, .yellow, .green, .blue, .purple]
        let images = colors.map { image(color: $0, size: CGSize(width: 100, height: 100)) }
        let segments = images.map { CameraSegment.image($0, nil, 0.5, .init(source: .kanvas_camera)) }
        handler.load(segments: segments, showLoading: {}, hideLoading: {}) { generated in
            e.fulfill()
        }
        wait(for: [e], timeout: 1.0)

        //
        // Act
        //

        let times: [TimeInterval] = [0.0, 0.3, 0.6, 0.9, 1.2, 1.5, 1.8, 2.1, 2.4, 2.7, 3.0, 3.1]
        let thumbnails = times.map { handler.getThumbnail(at: $0) }
        let expectedColors: [UIColor] = [.red, .red, .orange, .orange, .yellow, .green, .green, .blue, .blue, .purple, .purple, .purple]

        //
        // Assert
        //

        for (i, expectedColor) in expectedColors.enumerated() {
            let actualColor = thumbnails[i]?.getDominantColors(count: 2)[0]
            guard let actualRGB = actualColor?.calculateRGBComponents() else {
                XCTFail()
                return
            }
            let expectedRGB = expectedColor.calculateRGBComponents()
            XCTAssertEqual(actualRGB.red, expectedRGB.red, accuracy: 0.05)
            XCTAssertEqual(actualRGB.green, expectedRGB.green, accuracy: 0.05)
            XCTAssertEqual(actualRGB.blue, expectedRGB.blue, accuracy: 0.05)
        }
    }

}
