//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

enum EditionOption: Int {
    
    case gif
    case filter
    case text
    case media
    case drawing
    
    var text: String {
        switch self {
        case .gif:
            return "Create GIF"
        case .filter:
            return "Filters"
        case .text:
            return "Text"
        case .media:
            return "Stickers"
        case .drawing:
            return "Drawing"
        }
    }
}
