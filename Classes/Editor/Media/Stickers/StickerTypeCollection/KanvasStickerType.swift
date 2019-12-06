//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Representation of a StickerType to be created by KanvasStickerProvider.
public struct KanvasStickerType: StickerType, Equatable {
    
    let id: String
    let description: String
    let image: KanvasSticker.Sizes
    let sponsored: Bool
    let title: String?
    let stickers: [Sticker]
    
    // MARK: - StickerType Protocol
    
    public func getImageUrl() -> String {
        return image.original.url.absoluteString
    }
    
    public func getStickers() -> [Sticker] {
        return stickers
    }
    
    public func isEqual(to stickerType: StickerType) -> Bool {
        guard let kanvasStickerType = stickerType as? KanvasStickerType else { return false }
        return self == kanvasStickerType
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: KanvasStickerType, rhs: KanvasStickerType) -> Bool {
        return lhs.getImageUrl() == rhs.getImageUrl()
    }
}
