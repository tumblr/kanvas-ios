//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import KanvasCamera
import Foundation

final class StickerProviderStub: StickerProvider {
    
    func getStickerTypes() -> [StickerType] {
        return []
    }
    
    func getStickers(for stickerType: StickerType) -> [Sticker] {
        return []
    }
}
