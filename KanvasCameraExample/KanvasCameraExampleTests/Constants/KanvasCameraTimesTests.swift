//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import AVFoundation
import Foundation
import XCTest

final class KanvasCameraTimesTests: XCTestCase {

    func testVideoRecordingTime() {
        XCTAssert(KanvasCameraTimes.videoRecordingTime == 30, "Returned value does not match expected value")
    }

    func testGifRecordingTime() {
        XCTAssert(KanvasCameraTimes.gifRecordingTime == 1, "Returned value does not match expected value")
    }

    func testStopMotionFrameDuration() {
        XCTAssert(KanvasCameraTimes.singlePhotoWithVideoFrameDuration == 300, "Returned value does not match expected value")
    }

    func testStopMotionFrameTimescale() {
        XCTAssert(KanvasCameraTimes.stopMotionFrameTimescale == 600, "Returned value does not match expected value")
    }

    func testStopMotionFrameTime() {
        XCTAssert(CMTimeCompare(KanvasCameraTimes.stopMotionFrameTime, CMTime(value: 300, timescale: 600)) == 0, "Returned value does not match expected value")
    }

    func testStopMotionFrameTimeInterval() {
        XCTAssert(KanvasCameraTimes.stopMotionFrameTimeInterval == 0.5, "Returned value does not match expected value")
    }

    func testGifPreferredFramesPerSecond() {
        XCTAssert(KanvasCameraTimes.gifPreferredFramesPerSecond == 10, "Returned value does not match expected value")
    }

    func testGifTotalFrames() {
        XCTAssert(KanvasCameraTimes.gifTotalFrames == 10, "Returned value does not match expected value")
    }

    func testGifTimeValue() {
        XCTAssert(KanvasCameraTimes.gifTimeValue == 10, "Returned value does not match expected value")
    }

    func testGifTimescale() {
        XCTAssert(KanvasCameraTimes.gifTimeScale == 100, "Returned value does not match expected value")
    }

    func testGifFrameTime() {
        XCTAssert(CMTimeCompare(KanvasCameraTimes.gifFrameTime, CMTime(value: 10, timescale: 100)) == 0, "Returned value does not match expected value")
    }

}
