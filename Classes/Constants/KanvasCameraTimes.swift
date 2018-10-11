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
    static let VideoRecordingTime: TimeInterval = 15

    // GifRecordingTime: the maximum amount of time for each gif (before reversing)
    static let GifRecordingTime: TimeInterval = 1

    static func recordingTime(for mode: CameraMode) -> TimeInterval {
        switch mode {
        case .photo: return 0
        case .gif: return GifRecordingTime
        case .stopMotion: return VideoRecordingTime
        }
    }
    // MARK: - Stop motion

    // OnlyImagesFrameDuration: the duration value of each photo clip in a video if there are ONLY videos
    static let OnlyImagesFrameDuration: CMTimeValue = 120
    
    // SinglePhotoWithVideoFrameDuration: the duration value of a single photo exported as a video. Also applies to photos exported with video
    static let SinglePhotoWithVideoFrameDuration: CMTimeValue = 300

    // StopMotionFrameTimescale: the timescale used for creating videos
    static let StopMotionFrameTimescale: CMTimeScale = 600

    // StopMotionFrameTime: the CMTime for each frame composed from the duration and timescale
    static let StopMotionFrameTime: CMTime = CMTime(value: SinglePhotoWithVideoFrameDuration, timescale: StopMotionFrameTimescale)

    // StopMotionFrameTimeInterval: the equivalent amount of seconds for each frame time
    static let StopMotionFrameTimeInterval: TimeInterval = CMTimeGetSeconds(StopMotionFrameTime)

    // MARK: - Gif

    // GifPreferredFramesPerSecond: the interval that frames will be captured
    static let GifPreferredFramesPerSecond = 10

    // GifTotalFrames: the total number of captured frames before reversing
    static let GifTotalFrames = 10

    // GifTimeValue: the time duration value of each gif frame on export
    static let GifTimeValue: CMTimeValue = 10

    // GifTimeScale: the timescale used for each gif frame
    static let GifTimeScale: CMTimeScale = Int32(GifTimeValue * Int64(KanvasCameraTimes.GifPreferredFramesPerSecond))

    // GifFrameTime: the composed CMTime from the duration and timescale
    static let GifFrameTime: CMTime = CMTimeMake(value: GifTimeValue, timescale: GifTimeScale)

    // MARK: - Other

    /// the wait time for threads
    static let SleepTime: TimeInterval = 0.1

}
