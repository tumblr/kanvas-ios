//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

enum EditionOption: Int {
    
    case gif
    case filter
    case text
    case media
    case drawing
    case cropRotate
    
    var text: String {
        switch self {
        case .gif:
            return NSLocalizedString("EditorGIF", value: "Create GIF", comment: "Label for the GIF option in the editor tools")
        case .filter:
            return NSLocalizedString("EditorFilters", value: "Filters", comment: "Label for the filters option in the editor tools")
        case .text:
            return NSLocalizedString("EditorText", value: "Text", comment: "Label for the text option in the editor tools")
        case .media:
            return NSLocalizedString("EditorMedia", value: "Media", comment: "Label for the media option in the editor tools")
        case .drawing:
            return NSLocalizedString("EditorDrawing", value: "Drawing", comment: "Label for the drawing option in the editor tools")
        case .cropRotate:
            return NSLocalizedString("EditorCropRotate", value: "Crop/Rotate", comment: "Label for the crop rotate option in the editor tools")
        }
    }
}
