//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

public protocol StickerProviderDelegate: class {
    /// Callback for when the sticker request has finished loading
    ///
    /// - Parameter stickerTypes: the collection of sticker types from the API
    func didLoadStickerTypes(_ stickerTypes: [StickerType])
}

public protocol StickerProvider {
    
    /// Designated initializer for the class.
    init()
    
    /// Starts an API call to fetch the sticker types.
    func getStickerTypes()
    
    /// Sets a StickerProviderDelegate in StickerProvider
    ///
    /// - Parameter delegate: the new delegate.
    func setDelegate(delegate: StickerProviderDelegate)
}
