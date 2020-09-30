//
//  GifMakerSettings.swift
//  KanvasCamera
//
//  Created by Jimmy Schementi on 6/16/20.
//

/// Settings for the GIF maker
struct GIFMakerSettings {

    static let defaultRate: Float = 1.0

    static let defaultPlaybackMode = PlaybackOption.loop

    /// Playback rate. 1.0 is original speed, 0.5 is 1/2 speed, etc...
    var rate: Float

    /// Frame to start playback at
    var startIndex: Int

    /// Frame to end playback at
    var endIndex: Int

    /// Playback behavior (loop, rebound, etc)
    var playbackMode: PlaybackOption

    struct Initial {
        var rate: Float?
        var playbackMode: PlaybackOption?
        var startTime: TimeInterval?
        var endTime: TimeInterval?

        func settings(frames: [MediaFrame]) -> GIFMakerSettings {
            let rate = self.rate ?? GIFMakerSettings.defaultRate
            let playbackMode = self.playbackMode ?? GIFMakerSettings.defaultPlaybackMode
            var startIndex: Int
            if let startTime = startTime,
                let index = MediaFrameGetFrame(frames, at: startTime)?.0 {
                startIndex = index
            }
            else {
                startIndex = 0
            }
            var endIndex: Int
            if let endTime = endTime,
                let index = MediaFrameGetFrame(frames, at: endTime)?.0 {
                endIndex = index
            }
            else {
                endIndex = max(frames.count - 1, 0)
            }
            return GIFMakerSettings(rate: rate, startIndex: startIndex, endIndex: endIndex, playbackMode: playbackMode)
        }
    }
}
