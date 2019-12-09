//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

// the values for timing and frame intervals throughout the module
struct KanvasCameraTimes {
    // MARK: - Shooting

    /// VideoRecordingTime: the maximum recording time for each video clip
    static let videoRecordingTime: TimeInterval = 30

    /// gifTapRecordingTime: the recording time for a GIF when tapping the shutter (before reversing)
    static let gifTapRecordingTime: TimeInterval = 1

    /// gifHoldRecordingTime: the recording time for a GIF when holding the shutter (before reversing)
    static let gifHoldRecordingTime: TimeInterval = 3

    /// Returns the recording time for the mode and whether the shutter is held or not
    /// - Parameter mode: camera mode
    /// - Parameter hold: whether the shutter is held or not
    /// - Returns: the TimeInterval
    static func recordingTime(for mode: CameraMode, hold: Bool = false) -> TimeInterval {
        switch mode.group {
        case .photo: return 0
        case .gif: return !hold ? gifTapRecordingTime : gifHoldRecordingTime
        case .video: return videoRecordingTime
        }
    }

    // MARK: - Stop motion

    /// OnlyImagesFrameDuration: the duration value of each photo clip in a video if there are ONLY videos
    static let onlyImagesFrameDuration: CMTimeValue = 120
    
    /// SinglePhotoWithVideoFrameDuration: the duration value of a single photo exported as a video. Also applies to photos exported with video
    static let singlePhotoWithVideoFrameDuration: CMTimeValue = 300

    /// StopMotionFrameTimescale: the timescale used for creating videos
    static let stopMotionFrameTimescale: CMTimeScale = 600

    /// StopMotionFrameTime: the CMTime for each frame composed from the duration and timescale
    static let stopMotionFrameTime: CMTime = CMTime(value: singlePhotoWithVideoFrameDuration, timescale: stopMotionFrameTimescale)

    /// StopMotionFrameTimeInterval: the equivalent amount of seconds for each frame time
    static let stopMotionFrameTimeInterval: TimeInterval = CMTimeGetSeconds(stopMotionFrameTime)

    // MARK: - Gif

    /// gifPreferredFramesPerSecond: the interval that frames will be captured in GIF mode
    static let gifPreferredFramesPerSecond = 10

    /// gifTapNumberOfFrames: the number of frames to record when tapping the shutter in GIF mode
    static let gifTapNumberOfFrames = Int(KanvasCameraTimes.gifTapRecordingTime * Double(KanvasCameraTimes.gifPreferredFramesPerSecond))

    /// gifHoldNumberOfFrames: the number of frames to record when holding the shutter in GIF mode
    static let gifHoldNumberOfFrames = Int(KanvasCameraTimes.gifHoldRecordingTime * Double(KanvasCameraTimes.gifPreferredFramesPerSecond))

    // MARK: - Other

    /// the wait time for threads
    static let sleepTime: TimeInterval = 0.1

}
