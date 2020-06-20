//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

struct GIFMakerSettings {

    /// Playback rate. 1.0 is original speed, 0.5 is 1/2 speed, etc...
    var rate: Float

    /// Frame to start playback at
    var startIndex: Int

    /// Frame to end playback at
    var endIndex: Int

    /// Playback behavior (loop, rebound, etc)
    var playbackMode: PlaybackOption
}
