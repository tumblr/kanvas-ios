//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// A representation of a playback option to be presented in PlaybackController
enum PlaybackOption: String {
    case loop
    case rebound
    case reverse
    
    /// Localized string for the option.
    var text: String {
        switch self {
        case .loop:
            return NSLocalizedString("Loop", comment: "Loop playback mode")
        case .rebound:
            return NSLocalizedString("Rebound", comment: "Rebound playback mode")
        case .reverse:
            return NSLocalizedString("Reverse", comment: "Reverse playback mode")
        }
    }
}
