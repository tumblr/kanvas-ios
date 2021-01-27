//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

enum DrawerTabBarOption: String {
    case stickers
    
    var description: String {
        switch self {
        case .stickers:
            return NSLocalizedString("Stickers", comment: "Stickers tab text in media drawer")
        }
    }
}
