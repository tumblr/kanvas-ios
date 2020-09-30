//
// Created by Tony Cheng on 8/16/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import Foundation
import XCTest

final class KanvasCameraTimesTests: XCTestCase {

    func testVideoRecordingTime() {
        XCTAssert(KanvasCameraTimes.videoRecordingTime == 30, "Returned value does not match expected value")
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

    func testGifTapRecordingTime() {
        XCTAssert(KanvasCameraTimes.gifTapRecordingTime == 1, "Returned value does not match expected value")
    }

    func testGifHoldRecordingTime() {
        if Device.isIPhone6P || Device.isIPhone6 {
            XCTAssert(KanvasCameraTimes.gifTapRecordingTime == 1, "Returned value does not match expected value")
        }
        else {
            XCTAssert(KanvasCameraTimes.gifHoldRecordingTime == 3, "Returned value does not match expected value")
        }
    }

    func testGifPreferredFramesPerSecond() {
        XCTAssert(KanvasCameraTimes.gifPreferredFramesPerSecond == 10, "Returned value does not match expected value")
    }

    func testGifTapTotalFrames() {
        XCTAssertEqual(KanvasCameraTimes.gifTapNumberOfFrames, 10, "Returned value does not match expected value")
    }

    func testGifHoldTotalFrames() {
        if Device.isIPhone6P || Device.isIPhone6 {
            XCTAssertEqual(KanvasCameraTimes.gifHoldNumberOfFrames, 10, "Returned value does not match expected value")
        }
        else {
            XCTAssertEqual(KanvasCameraTimes.gifHoldNumberOfFrames, 30, "Returned value does not match expected value")
        }
    }

    func testGifRecordingTime() {
        XCTAssertEqual(KanvasCameraTimes.recordingTime(for: .gif, hold: false), 1, "Tapping the GIF shutter should record for 1 second")
        if Device.isIPhone6P || Device.isIPhone6 {
            XCTAssertEqual(KanvasCameraTimes.recordingTime(for: .gif, hold: true), 1, "Holding the GIF shutter should record for 1 second")
        }
        else {
            XCTAssertEqual(KanvasCameraTimes.recordingTime(for: .gif, hold: true), 3, "Holding the GIF shutter should record for 3 seconds")
        }

    }

}
