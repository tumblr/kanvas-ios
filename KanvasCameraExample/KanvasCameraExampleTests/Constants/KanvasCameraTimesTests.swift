//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
import AVFoundation
@testable import KanvasCamera

final class KanvasCameraTimesTests: XCTestCase {

    func testVideoRecordingTime() {
        XCTAssert(KanvasCameraTimes.VideoRecordingTime == 15, "Returned value does not match expected value")
    }

    func testGifRecordingTime() {
        XCTAssert(KanvasCameraTimes.GifRecordingTime == 1, "Returned value does not match expected value")
    }

    func testStopMotionFrameDuration() {
        XCTAssert(KanvasCameraTimes.StopMotionFrameDuration == 40, "Returned value does not match expected value")
    }

    func testStopMotionFrameTimescale() {
        XCTAssert(KanvasCameraTimes.StopMotionFrameTimescale == 200, "Returned value does not match expected value")
    }

    func testStopMotionFrameTime() {
        XCTAssert(CMTimeCompare(KanvasCameraTimes.StopMotionFrameTime, CMTime(value: 40, timescale: 200)) == 0, "Returned value does not match expected value")
    }

    func testStopMotionFrameTimeInterval() {
        XCTAssert(KanvasCameraTimes.StopMotionFrameTimeInterval == 0.2, "Returned value does not match expected value")
    }

    func testGifPreferredFramesPerSecond() {
        XCTAssert(KanvasCameraTimes.GifPreferredFramesPerSecond == 10, "Returned value does not match expected value")
    }

    func testGifTotalFrames() {
        XCTAssert(KanvasCameraTimes.GifTotalFrames == 10, "Returned value does not match expected value")
    }

    func testGifTimeValue() {
        XCTAssert(KanvasCameraTimes.GifTimeValue == 10, "Returned value does not match expected value")
    }

    func testGifTimescale() {
        XCTAssert(KanvasCameraTimes.GifTimeScale == 100, "Returned value does not match expected value")
    }

    func testGifFrameTime() {
        XCTAssert(CMTimeCompare(KanvasCameraTimes.GifFrameTime, CMTime(value: 10, timescale: 100)) == 0, "Returned value does not match expected value")
    }

}
