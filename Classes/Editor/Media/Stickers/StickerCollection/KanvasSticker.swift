//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct KanvasSticker: Sticker, Hashable {
    
    public struct Sizes: Equatable {
        let original: Image
        let alternate: [Image]
    }

    public struct Image: Hashable {
        let url: URL
        let width: Int
        let height: Int

        public func hash(into hasher: inout Hasher) {
            hasher.combine(url.hashValue)
            hasher.combine(width.hashValue)
            hasher.combine(height.hashValue)
        }
    }

    /// The sticker's id as a String
    let id: String
    
    /// String description of the sticker
    let description: String
    
    /// The sticker's image as Sizes
    let image: Sizes

    /// True if the sticker is part of a sponsored StickerPack
    let sponsored: Bool
    
    /// Sticker ID used for analytics/logging purposes
    public var analyticsID: String {
        return id
    }
    
    // MARK: - Sticker
    
    public func getImageUrl() -> String {
        return image.original.url.absoluteString
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
    
    /// Gets the `Image` that is the closest to `size` but always greater then it. So if you pass in 400, and there are 300, 500, 1200,
    /// then you will be returned the 500 varient.
    /// But the original size is currently 1200, so if you pass in anything larger then it, you will get the 1200 varient.
    ///
    /// - Parameter size: The size you want the image to be in pixels
    /// - Returns: The image that is the closest to the `size`
    func sizeClosestTo(_ size: CGSize) -> Image {
        let filteredSizes = image.alternate.filter { $0.width >= Int(size.width) && $0.height >= Int(size.height) }
        return filteredSizes.first ?? image.original
    }

    /// Gets the `Image` that is the smallest varient available
    ///
    /// - Returns: The image that is the smallest
    func smallestSize() -> Image {
        let sortedSizes = image.alternate.lazy.sorted { (lhs, rhs) -> Bool in
            return lhs.width < rhs.width && lhs.height < rhs.height
        }
        return sortedSizes.first ?? image.original
    }
}
