//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class KanvasStickerTypeRequestConverterTests: XCTestCase {
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                XCTFail("Parsing string into Dictionary failed")
            }
        }
        return []
    }
    
    private func createStickerTypeDictionary() -> KanvasSticker {
        let json = "{ \"description\": \"description\", \"id\" = \"0\", \"image\": { \"alt_sizes\": { \"height\": \"250\", \"url\": \"https://assets.tumblr.com/images/stickers/Folder.png\", \"width\": \"250\" }, \"original_size\": { \"height\": \"250\" \"url\": \"https://assets.tumblr.com/images/stickers/Folder.png\", \"width\": \"250\" } }, \"object_type\": \"sticker_pack\", \"sponsored\": \"0\", \"stickers\": [], \"title\": \"title\" }"
        return convertToDictionary(text: json)
    }
    
    private func createStickerType() -> KanvasSticker {
        let imageUrl = URL(string: "https://assets.tumblr.com/images/stickers/Folder.png")
        let original = Image(url: URL(string: imageUrl), width: 250, height: 250)
        let alternate = Image(url: URL(string: imageUrl), width: 250, height: 250)
        let images = Image.Sizes(original: original, alternate: alternate)
        let stickerType = KanvasStickerType(id: 0, description: "description", image: images,
                                            sponsored: false, title: "title", stickers: [])
        
        return stickerType
    }
    
    func testResponseConverter() {
        let requestConverter = KanvasStickerTypeRequestConverter()
        
        let stickerType = createStickerType()
        let stickerTypeDictionary = createStickerTypeDictionary()
        let parsedStickerType = requestConverer.parseStickerType(stickerTypeDictionary)
        
        XCTAssertEqual(parsedStickerType, stickerType, "Sticker types do not match")
    }
}
