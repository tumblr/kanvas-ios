//
//  StickerProvider.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 19/11/2019.
//

public protocol StickerProviderDelegate: class {
    /// Callback for when the sticker request has finished loading
    ///
    /// - Parameter stickerTypes: the collection of sticker types from the API
    func didLoadStickerTypes(_ stickerTypes: [StickerType])
}

public protocol StickerProvider {
    
    /// Starts an API call to fetch the sticker types.
    func getStickerTypes()
    
    /// Sets a StickerProviderDelegate in StickerProvider
    ///
    /// - Parameter delegate: the new delegate.
    func setDelegate(delegate: StickerProviderDelegate)
    
    func loader() -> KanvasStickerLoader?
}
