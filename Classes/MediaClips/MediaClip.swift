//
// Created by Tony Cheng on 8/29/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
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
