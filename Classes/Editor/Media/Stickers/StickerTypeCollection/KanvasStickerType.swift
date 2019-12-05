//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct KanvasStickerType: StickerType, Equatable, Hashable {
    
    let id: String
    let description: String
    let image: KanvasSticker.Sizes
    let sponsored: Bool
    let title: String?
    let stickers: [Sticker]
    
    // MARK: - StickerType
    
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
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id.hashValue) }
}
