//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
import UIKit
enum EditionOption: Int {
    
    case gif
    case filter
    case text
    case media
    case drawing
    
    var text: String {
        switch self {
        case .gif:
            return NSLocalizedString("EditorGIF", comment: "Label for the GIF option in the editor tools")
        case .filter:
            return NSLocalizedString("EditorFilters", comment: "Label for the filters option in the editor tools")
        case .text:
            return NSLocalizedString("EditorText", comment: "Label for the text option in the editor tools")
        case .media:
            return NSLocalizedString("EditorMedia", comment: "Label for the media option in the editor tools")
        case .drawing:
            return NSLocalizedString("EditorDrawing", comment: "Label for the drawing option in the editor tools")
        }
    }
}
