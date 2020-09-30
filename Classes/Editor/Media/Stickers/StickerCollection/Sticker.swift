//
//  Sticker.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 05/12/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

import Foundation
import UIKit

/// A representation of a sticker in the media drawer
public struct Sticker {
        
    let id: String
    let imageUrl: String
    
    // MARK: - Initializers
    
    public init(id: String, imageUrl: String) {
        self.id = id
        self.imageUrl = imageUrl
    }
}
