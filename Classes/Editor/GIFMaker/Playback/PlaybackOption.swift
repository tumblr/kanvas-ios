//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// A representation of a playback option to be presented in the selector.
enum PlaybackOption: String, OptionSelectorItem {

    case loop
    case rebound
    case reverse
    
    /// Localized string for the option.
    var description: String {
        switch self {
        case .loop:
            return NSLocalizedString("GIFLoop", comment: "Loop playback mode")
        case .rebound:
            return NSLocalizedString("GIFRebound", comment: "Rebound playback mode")
        case .reverse:
            return NSLocalizedString("GIFReverseLoop", comment: "Reverse playback mode")
        }
    }
    
}
