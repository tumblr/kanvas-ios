//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import NetworkAbstractions

private struct Constants {
    static let stickerPacksKey = "sticker_packs"
    static let idKey = "id"
    static let sponsoredKey = "sponsored"
    static let titleKey = "title"
    static let descriptionKey = "description"
    static let imageKey = "image"
    static let stickersKey = "stickers"
    static let originalSizeKey = "original_size"
    static let alternateSizesKey = "alt_sizes"
    static let urlKey = "url"
    static let widthKey = "width"
    static let heightKey = "height"
}

public struct KanvasStickerTypeResponseConverter: RequestSenderResponseConverter {
    
    public typealias ResponseType = [StickerType]

    public typealias NetworkingErrorModelType = Void

    /// Converts a network response into a network result doing any JSON parsing for StickerPacks
    ///
    /// - Parameter response: The response from the network controller
    /// - Returns: A network result that contains StickerPacks if able to extract any from the response's JSON or an empty StickerPack array if there was an error
    public func convertResponse(_ response: Response) -> NetworkAbstractions.Result<[StickerType], NetworkingError<Void>> {

        if let stickerPacksJSON = response.responseDictionary[Constants.stickerPacksKey] as? [NSDictionary] {
            return .value(stickerPacksJSON.compactMap(parseStickerPack))
        }

        return .value([])
    }

    public func parseStickerPack(_ json: NSDictionary) -> StickerType? {
        guard let id = json[Constants.idKey] as? String,
            let description = json[Constants.descriptionKey] as? String,
            let imageSizesJSON = json[Constants.imageKey] as? NSDictionary,
            let imageSizes = parseStickerSize(imageSizesJSON),
            let stickersJSON = json[Constants.stickersKey] as? [NSDictionary],
            stickersJSON.count > 0 else {
                return nil
        }
        
        let sponsored = json.boolValue(forKey: Constants.sponsoredKey as NSString)
        let title: String? = json[Constants.titleKey] as? String
        
        let stickers: [Sticker] = stickersJSON.compactMap { parseSticker($0, sponsored: sponsored) }

        let pack = KanvasStickerType(id: id, description: description, image: imageSizes, sponsored: sponsored, title: title, stickers: stickers)
        return pack
    }

    private func parseSticker(_ json: NSDictionary, sponsored: Bool = false) -> Sticker? {
        guard let id = json[Constants.idKey] as? String,
            let description = json[Constants.descriptionKey] as? String,
            let sizeJSON = json[Constants.imageKey] as? NSDictionary,
            let imageSize = parseStickerSize(sizeJSON) else {
                return nil
        }

        let sticker = KanvasSticker(id: id, description: description, image: imageSize, sponsored: sponsored)
        return sticker
    }

    private func parseImage(_ json: NSDictionary) -> KanvasSticker.Image? {
        guard let urlString = json[Constants.urlKey] as? String,
            let url = URL(string: urlString),
            let width = json[Constants.widthKey] as? Int,
            let height = json[Constants.heightKey] as? Int else {
                return nil
        }

        let image = KanvasSticker.Image(url: url, width: width, height: height)
        return image
    }

    private func parseStickerSize(_ json: NSDictionary) -> KanvasSticker.Sizes? {
        guard let originalJSON = json[Constants.originalSizeKey] as? NSDictionary,
            let alternateJSON = json[Constants.alternateSizesKey] as? [NSDictionary],
            let original = parseImage(originalJSON),
            alternateJSON.count > 0 else {
                return nil
        }
        let alternates: [KanvasSticker.Image] = alternateJSON.compactMap(parseImage)
        let size = KanvasSticker.Sizes(original: original, alternate: alternates)
        return size
    }
}
