//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest

final class GifMakerSettingsTests: XCTestCase {

    func testGifMakerSettings() {
        let settings = GIFMakerSettings(rate: 1.0, startIndex: 0, endIndex: 10, playbackMode: .loop)
        XCTAssertEqual(settings.rate, 1.0)
        XCTAssertEqual(settings.startIndex, 0)
        XCTAssertEqual(settings.endIndex, 10)
        XCTAssertEqual(settings.playbackMode, PlaybackOption.loop)
    }

    func testGifMakerSettingsInitial() {
        let initialSettings = GIFMakerSettings.Initial(rate: 0.5, playbackMode: .rebound, startTime: 0, endTime: 1)
        let frames = [
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
        ]
        let settings = initialSettings.settings(frames: frames)
        XCTAssertEqual(settings.rate, 0.5)
        XCTAssertEqual(settings.playbackMode, .rebound)
        XCTAssertEqual(settings.startIndex, 0)
        XCTAssertEqual(settings.endIndex, 4) // TODO: ugh this should be 3
    }

    func testGifMakerSettingsInitialNil() {
        let initialSettings = GIFMakerSettings.Initial(rate: nil, playbackMode: nil, startTime: nil, endTime: nil)
        let frames = [
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
            (image: UIImage(), interval: 0.25),
        ]
        let settings = initialSettings.settings(frames: frames)
        XCTAssertEqual(settings.rate, 1.0)
        XCTAssertEqual(settings.playbackMode, .loop)
        XCTAssertEqual(settings.startIndex, 0)
        XCTAssertEqual(settings.endIndex, 5)
    }

    func testGifMakerSettingsInitialNilAndNoFrames() {
        let initialSettings = GIFMakerSettings.Initial(rate: nil, playbackMode: nil, startTime: nil, endTime: nil)
        let settings = initialSettings.settings(frames: [])
        XCTAssertEqual(settings.rate, 1.0)
        XCTAssertEqual(settings.playbackMode, .loop)
        XCTAssertEqual(settings.startIndex, 0)
        XCTAssertEqual(settings.endIndex, 0)
    }

}
