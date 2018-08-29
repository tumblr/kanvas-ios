//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// A representation for a camera segment to be presented in the MediaClipsEditorController
struct MediaClip {
    /// The image to represent the photo or video
    let representativeFrame: UIImage
    /// Text to display for each clip
    let overlayText: String?
}
