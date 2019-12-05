//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import TMTumblrSDK

public protocol StickerProviderDelegate: class {
    func didLoadStickerTypes(_ stickerTypes: [StickerType])
}

public protocol StickerProvider {
    init(session: TMSession)
    func getStickerTypes()
    func setDelegate(delegate: StickerProviderDelegate)
}
