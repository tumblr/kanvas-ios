//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// A representation for a sticker type to be presented in the sticker type collection
public struct StickerType: Equatable {
    
    public let baseUrl: String
    public let keyword: String
    public let thumbUrl: String
    public let count: Int
    
    public var imageUrl: String {
        return "\(baseUrl)\(keyword)/\(thumbUrl)"
    }
    
    public init(baseUrl: String, keyword: String, thumbUrl: String, count: Int) {
        self.baseUrl = baseUrl
        self.keyword = keyword
        self.thumbUrl = thumbUrl
        self.count = count
    }
}
