//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// A representation for a sticker type to be presented in the Media Drawer
struct StickerType {
    
    let baseUrl: String
    let keyword: String
    let thumbUrl: String
    let count: Int
    
    var imageUrl: String {
        return "\(baseUrl)\(keyword)/\(thumbUrl)"
    }
    
    init(baseUrl: String, keyword: String, thumbUrl: String, count: Int) {
        self.baseUrl = baseUrl
        self.keyword = keyword
        self.thumbUrl = thumbUrl
        self.count = count
    }
}
