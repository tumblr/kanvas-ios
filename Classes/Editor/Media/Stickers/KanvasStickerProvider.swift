//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Sticker provider to be used in Orangina
public final class KanvasStickerProvider: StickerProvider {
    
    public init() {
        
    }
    
    public func getStickerTypes() -> [StickerType] {
        return []
    }
    
    public func getStickers(for stickerType: StickerType) -> [Sticker] {
        return []
    }
}
