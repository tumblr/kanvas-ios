//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit
import KanvasCamera

/// Constants for ExperimentalSticker
private struct Constants {
    static let twoDigitsFormat: String = "%02d"
}

/// An implementation of Sticker to be created by ExperimentalStickerProvider
public struct ExperimentalSticker: Sticker {
    
    private let baseUrl: String
    private let keyword: String
    private let number: Int
    private let imageExtension: String
    
    public init(baseUrl: String, keyword: String, number: Int, imageExtension: String = "png") {
        self.baseUrl = baseUrl
        self.keyword = keyword
        self.number = number
        self.imageExtension = imageExtension
    }
    
    // MARK: - Sticker Protocol
    
    public func getImageUrl() -> String {
        return "\(baseUrl)\(keyword)/\(String(format: Constants.twoDigitsFormat, number)).\(imageExtension)"
    }
}
