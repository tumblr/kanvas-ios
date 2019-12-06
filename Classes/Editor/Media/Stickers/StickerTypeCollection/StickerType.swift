//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

public protocol StickerType {
    
    /// Gets the url of the sticker image as a string.
    func getImageUrl() -> String
    
    /// Gets the list of stickers for this sticker type.
    func getStickers() -> [Sticker]
    
    /// Compares this object with another and returns true if they are equal.
    ///
    /// - Parameter stickerType: Object to compare this object with.
    func isEqual(to stickerType: StickerType) -> Bool
}
