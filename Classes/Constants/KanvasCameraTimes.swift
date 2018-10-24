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

    // VideoRecordingTime: the maximum recording time for each video clip
    static let videoRecordingTime: TimeInterval = 15

    // GifRecordingTime: the maximum amount of time for each gif (before reversing)
    static let gifRecordingTime: TimeInterval = 1

    static func recordingTime(for mode: CameraMode) -> TimeInterval {
        switch mode {
        case .photo: return 0
        case .gif: return gifRecordingTime
        case .stopMotion: return videoRecordingTime
        }
    }
    // MARK: - Stop motion

    // OnlyImagesFrameDuration: the duration value of each photo clip in a video if there are ONLY videos
    static let onlyImagesFrameDuration: CMTimeValue = 120
    
    // SinglePhotoWithVideoFrameDuration: the duration value of a single photo exported as a video. Also applies to photos exported with video
    static let singlePhotoWithVideoFrameDuration: CMTimeValue = 300

    // StopMotionFrameTimescale: the timescale used for creating videos
    static let stopMotionFrameTimescale: CMTimeScale = 600

    // StopMotionFrameTime: the CMTime for each frame composed from the duration and timescale
    static let stopMotionFrameTime: CMTime = CMTime(value: singlePhotoWithVideoFrameDuration, timescale: stopMotionFrameTimescale)

    // StopMotionFrameTimeInterval: the equivalent amount of seconds for each frame time
    static let stopMotionFrameTimeInterval: TimeInterval = CMTimeGetSeconds(stopMotionFrameTime)

    // MARK: - Gif

    // GifPreferredFramesPerSecond: the interval that frames will be captured
    static let gifPreferredFramesPerSecond = 10

    // GifTotalFrames: the total number of captured frames before reversing
    static let gifTotalFrames = 10

    // GifTimeValue: the time duration value of each gif frame on export
    static let gifTimeValue: CMTimeValue = 10

    // GifTimeScale: the timescale used for each gif frame
    static let gifTimeScale: CMTimeScale = Int32(gifTimeValue * Int64(KanvasCameraTimes.gifPreferredFramesPerSecond))

    // GifFrameTime: the composed CMTime from the duration and timescale
    static let gifFrameTime: CMTime = CMTimeMake(value: gifTimeValue, timescale: gifTimeScale)

    // MARK: - Other

    /// the wait time for threads
    static let sleepTime: TimeInterval = 0.1

}
