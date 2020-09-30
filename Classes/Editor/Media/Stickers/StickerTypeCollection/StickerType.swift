//
//  StickerType.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 05/12/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

import Foundation
import UIKit

/// A representation of a sticker type in the media drawer
public struct StickerType: Equatable {
    
    let id: String
    let imageUrl: String
    let stickers: [Sticker]
    
    // MARK: - Initializers
    
    public init(id: String, imageUrl: String, stickers: [Sticker]) {
        self.id = id
        self.imageUrl = imageUrl
        self.stickers = stickers
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: StickerType, rhs: StickerType) -> Bool {
        return lhs.imageUrl == rhs.imageUrl
    }
}
