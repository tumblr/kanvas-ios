//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
import Foundation
import XCTest

final class KanvasTimesTests: XCTestCase {

    func testVideoRecordingTime() {
        XCTAssert(KanvasTimes.videoRecordingTime == 30, "Returned value does not match expected value")
    }

    func testStopMotionFrameDuration() {
        XCTAssert(KanvasTimes.singlePhotoWithVideoFrameDuration == 300, "Returned value does not match expected value")
    }

    func testStopMotionFrameTimescale() {
        XCTAssert(KanvasTimes.stopMotionFrameTimescale == 600, "Returned value does not match expected value")
    }

    func testStopMotionFrameTime() {
        XCTAssert(CMTimeCompare(KanvasTimes.stopMotionFrameTime, CMTime(value: 300, timescale: 600)) == 0, "Returned value does not match expected value")
    }

    func testStopMotionFrameTimeInterval() {
        XCTAssert(KanvasTimes.stopMotionFrameTimeInterval == 0.5, "Returned value does not match expected value")
    }

    func testGifTapRecordingTime() {
        XCTAssert(KanvasTimes.gifTapRecordingTime == 1, "Returned value does not match expected value")
    }

    func testGifHoldRecordingTime() {
        if Device.isIPhone6P || Device.isIPhone6 {
            XCTAssert(KanvasTimes.gifTapRecordingTime == 1, "Returned value does not match expected value")
        }
        else {
            XCTAssert(KanvasTimes.gifHoldRecordingTime == 3, "Returned value does not match expected value")
        }
    }

    func testGifPreferredFramesPerSecond() {
        XCTAssert(KanvasTimes.gifPreferredFramesPerSecond == 10, "Returned value does not match expected value")
    }

    func testGifTapTotalFrames() {
        XCTAssertEqual(KanvasTimes.gifTapNumberOfFrames, 10, "Returned value does not match expected value")
    }

    func testGifHoldTotalFrames() {
        if Device.isIPhone6P || Device.isIPhone6 {
            XCTAssertEqual(KanvasTimes.gifHoldNumberOfFrames, 10, "Returned value does not match expected value")
        }
        else {
            XCTAssertEqual(KanvasTimes.gifHoldNumberOfFrames, 30, "Returned value does not match expected value")
        }
    }

    func testGifRecordingTime() {
        XCTAssertEqual(KanvasTimes.recordingTime(for: .gif, hold: false), 1, "Tapping the GIF shutter should record for 1 second")
        if Device.isIPhone6P || Device.isIPhone6 {
            XCTAssertEqual(KanvasTimes.recordingTime(for: .gif, hold: true), 1, "Holding the GIF shutter should record for 1 second")
        }
        else {
            XCTAssertEqual(KanvasTimes.recordingTime(for: .gif, hold: true), 3, "Holding the GIF shutter should record for 3 seconds")
        }

    }

}
