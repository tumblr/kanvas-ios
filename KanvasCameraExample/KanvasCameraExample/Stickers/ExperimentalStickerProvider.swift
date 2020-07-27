//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import KanvasCamera
import ImageLoader

/// Constants for ExperimentalStickerProvider
private struct Constants {
    static let resourceName: String = "stickers"
    static let resourceExtension: String = "json"
    static let twoDigitsFormat: String = "%02d"
    static let imageExtension: String = "png"
}

extension CancelationToken: KanvasCancelable {

}

extension SDWebImageImageLoader: KanvasStickerLoader {
    public func loadSticker(at imageURL: URL, imageView: UIImageView?, completion: @escaping (UIImage?, Error?) -> Void) -> KanvasCancelable {
        let cancelableMaybe = loadImage(at: imageURL, OAuth: false, imageView: imageView, displayImageImmediately: true, preloadAllFrames: true, completion: completion) as? KanvasCancelable
        guard let cancelable = cancelableMaybe else {
            assertionFailure("Failed to get the proper cancelation token for loading a sticker")
            return CancelationToken {
                print("Can't cancel")
            }
        }
        return cancelable
    }
}

/// Class that obtains the stickers from the stickers file in the example app
public final class ExperimentalStickerProvider: StickerProvider {
    
    public func loader() -> KanvasStickerLoader? {
        return ImageLoaderProvider.makeImageLoader() as? KanvasStickerLoader
    }

    private weak var delegate: StickerProviderDelegate?
    
    // MARK: - StickerProvider Protocol
    
    public init() {

    }
    
    public func setDelegate(delegate: StickerProviderDelegate) {
        self.delegate = delegate
    }
    
    /// Gets the collection of stickers types
    public func getStickerTypes() {
        let data = getData()
        
        guard let providers = data["providers"] as? NSArray,
            let kanvasProvider = providers.firstObject as? Dictionary<String, Any>,
            let baseUrl = kanvasProvider["base_url"] as? String,
            let stickerList = data["stickers"] as? NSArray else {
                delegate?.didLoadStickerTypes([])
                return
        }
        
        var stickerTypes: [StickerType] = []
        
        stickerList.forEach { element in
            if let stickerItem = element as? Dictionary<String, Any>,
                let keyword = stickerItem["keyword"] as? String,
                let thumbUrl = stickerItem["thumb_url"] as? String,
                let count = stickerItem["count"] as? Int {
                
                var stickers: [Sticker] = []
                for number in 1...count {
                    let id = "\(keyword)_\(number)"
                    let imageUrl =  "\(baseUrl)\(keyword)/\(String(format: Constants.twoDigitsFormat, number)).\(Constants.imageExtension)"
                    stickers.append(Sticker(id: id, imageUrl: imageUrl))
                }
                
                let imageUrl = "\(baseUrl)\(keyword)/\(thumbUrl)"
                let stickerType = StickerType(id: keyword, imageUrl: imageUrl, stickers: stickers)
                
                stickerTypes.append(stickerType)
            }
        }
        
        delegate?.didLoadStickerTypes(stickerTypes)
    }
    
    // MARK: - Private utilities
    
    /// Creates a dictionary from the stickers JSON file
    private func getData() -> Dictionary<String, AnyObject> {
        if let path = Bundle(for: ExperimentalStickerProvider.self).path(forResource: "\(Constants.resourceName)", ofType: Constants.resourceExtension) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    return jsonResult
                }
            }
            catch {
                print("Error loading \(Constants.resourceName).\(Constants.resourceExtension)")
            }
        }
        
        return Dictionary<String, AnyObject>()
    }
}
