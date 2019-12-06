//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Representation of a Sticker to be created by KanvasStickerProvider.
public struct KanvasSticker: Sticker {
    
    public struct Sizes {
        let original: Image
        let alternate: [Image]
    }

    public struct Image {
        let url: URL
        let width: Int
        let height: Int
    }

    /// The sticker's id as a String
    let id: String
    
    /// Description of the sticker
    let description: String
    
    /// The sticker's image as Sizes
    let image: Sizes

    /// True if the sticker is part of a sponsored StickerPack
    let sponsored: Bool
    
    // MARK: - Sticker Protocol
    
    public func getImageUrl() -> String {
        return image.original.url.absoluteString
    }
}
