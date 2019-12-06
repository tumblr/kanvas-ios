//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import KanvasCamera

/// An implementation of StickerType to be created by ExperimentalStickerProvider
public class ExperimentalStickerType: StickerType, Equatable {
    
    public let baseUrl: String
    public let keyword: String
    public let thumbUrl: String
    public let count: Int

    public init(baseUrl: String, keyword: String, thumbUrl: String, count: Int) {
        self.baseUrl = baseUrl
        self.keyword = keyword
        self.thumbUrl = thumbUrl
        self.count = count
    }
    
    // MARK: - StickerType Protocol
    
    public func getImageUrl() -> String {
        return "\(baseUrl)\(keyword)/\(thumbUrl)"
    }
    
    public func getStickers() -> [Sticker] {
        var stickers: [Sticker] = []
        for number in 1...count {
            stickers.append(ExperimentalSticker(baseUrl: baseUrl, keyword: keyword, number: number))
        }
        return stickers
    }
    
    public func isEqual(to stickerType: StickerType) -> Bool {
        guard let experimentalStickerType = stickerType as? ExperimentalStickerType else { return false }
        return self == experimentalStickerType
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: ExperimentalStickerType, rhs: ExperimentalStickerType) -> Bool {
        return lhs.getImageUrl() == rhs.getImageUrl()
    }
}
