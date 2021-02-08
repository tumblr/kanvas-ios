//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation

// the values for timing and frame intervals throughout the module
struct KanvasTimes {
    // MARK: - Shooting

    /// VideoRecordingTime: the maximum recording time for each video clip
    static let videoRecordingTime: TimeInterval = 30

    /// gifTapRecordingTime: the recording time for a GIF when tapping the shutter (before reversing)
    static let gifTapRecordingTime: TimeInterval = 1

    /// gifHoldRecordingTime: the recording time for a GIF when holding the shutter (before reversing)
    /// FIXME: on an iPhone 6, we limit this to 1 seconds due to memory issues. GIF recording should be made less memory intensive.
    static let gifHoldRecordingTime: TimeInterval = Device.isIPhone6 || Device.isIPhone6P ? gifTapRecordingTime : 3

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

    /// OnlyImagesFrameDuration: the duration value of each photo clip in a video if there are ONLY photos
    static let onlyImagesFrameDuration: CMTimeValue = 120
    
    /// SinglePhotoWithVideoFrameDuration: the duration value of a single photo exported as a video. Also applies to photos exported with video
    static let singlePhotoWithVideoFrameDuration: CMTimeValue = 300

    /// StopMotionFrameTimescale: the timescale used for creating videos
    static let stopMotionFrameTimescale: CMTimeScale = 600

    /// OnlyImagesFrameTime: the CMTime for each frame when there are only photo clips
    static let onlyImagesFrameTime: CMTime = CMTime(value: onlyImagesFrameDuration, timescale: stopMotionFrameTimescale)

    /// StopMotionFrameTime: the CMTime for each frame
    static let stopMotionFrameTime: CMTime = CMTime(value: singlePhotoWithVideoFrameDuration, timescale: stopMotionFrameTimescale)

    /// OnlyImagesFrameTimeInterval: the equavalent amount of seconds for each frame when there are only photo clips
    static let onlyImagesFrameTimeInterval: TimeInterval = CMTimeGetSeconds(onlyImagesFrameTime)

    /// StopMotionFrameTimeInterval: the equivalent amount of seconds for each frame time
    static let stopMotionFrameTimeInterval: TimeInterval = CMTimeGetSeconds(stopMotionFrameTime)

    // MARK: - Gif

    /// gifPreferredFramesPerSecond: the interval that frames will be captured in GIF mode
    static let gifPreferredFramesPerSecond = 10

    /// gifTapNumberOfFrames: the number of frames to record when tapping the shutter in GIF mode
    static let gifTapNumberOfFrames = Int(KanvasTimes.gifTapRecordingTime * Double(KanvasTimes.gifPreferredFramesPerSecond))

    /// gifHoldNumberOfFrames: the number of frames to record when holding the shutter in GIF mode
    static let gifHoldNumberOfFrames = Int(KanvasTimes.gifHoldRecordingTime * Double(KanvasTimes.gifPreferredFramesPerSecond))

}
