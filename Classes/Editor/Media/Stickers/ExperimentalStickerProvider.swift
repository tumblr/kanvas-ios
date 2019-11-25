//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Constants for ExperimentalStickerProvider
private struct Constants {
    static let resourceDirectory: String = "Stickers"
    static let resourceName: String = "stickers"
    static let resourceExtension: String = "json"
}

/// Class that obtains the stickers from the stickers file in the example app
public final class ExperimentalStickerProvider: StickerProvider {
    
    public init() {
        
    }
    
    /// Creates a dictionary from the stickers JSON file
    func getData() -> Dictionary<String, AnyObject> {
        if let path = Bundle(for: ExperimentalStickerProvider.self).path(forResource: "\(Constants.resourceDirectory)/\(Constants.resourceName)", ofType: Constants.resourceExtension) {
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
    
    /// Gets the collection of stickers for a specific sticker type
    ///
    /// - Parameter stickerType: the sticker type
    public func getStickers(for stickerType: StickerType) -> [Sticker] {
        var stickers: [Sticker] = []
        for number in 1...stickerType.count {
            stickers.append(Sticker(baseUrl: stickerType.baseUrl, keyword: stickerType.keyword, number: number))
        }
        return stickers
    }
    
    /// Gets the collection of stickers types
    public func getStickerTypes() -> [StickerType] {
        let data = getData()
        
        guard let providers = data["providers"] as? NSArray,
            let kanvasProvider = providers.firstObject as? Dictionary<String, Any>,
            let baseUrl = kanvasProvider["base_url"] as? String,
            let stickerList = data["stickers"] as? NSArray else { return [] }
        
        var stickerType: [StickerType] = []
        
        stickerList.forEach { element in
            if let stickerItem = element as? Dictionary<String, Any>,
                let keyword = stickerItem["keyword"] as? String,
                let thumbUrl = stickerItem["thumb_url"] as? String,
                let count = stickerItem["count"] as? Int {
                stickerType.append(StickerType(baseUrl: baseUrl, keyword: keyword, thumbUrl: thumbUrl, count: count))
            }
        }
        
        return stickerType
    }
}
