//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// A representation of a sticker type in the media drawer
public struct StickerType: Equatable {
    
    let id: String
    let imageUrl: String
    let stickers: [Sticker]
    
    // MARK: - Initializers
    
    public init(id: String, imageUrl: String, stickers: [Sticker]) {
        self.id = id
        self.imageUrl = imageUrl
        self.stickers = stickers
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: StickerType, rhs: StickerType) -> Bool {
        return lhs.imageUrl == rhs.imageUrl
    }
}
