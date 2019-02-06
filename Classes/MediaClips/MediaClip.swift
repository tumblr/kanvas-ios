//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import AVFoundation
import UIKit

/// A representation for a camera segment to be presented in the MediaClipsEditorViewController
struct MediaClip {
    /// The image to represent the photo or video
    let representativeFrame: UIImage
    /// Text to display for each clip
    let overlayText: String?
    /// The last frame of the clip (if it is an image it will be similar to representative frame)
    var lastFrame: UIImage
}
