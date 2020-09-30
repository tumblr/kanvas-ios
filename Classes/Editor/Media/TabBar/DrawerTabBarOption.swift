//
//  DrawerTabBarOption.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 15/11/2019.
//

/// A representation of the tab bar option in the media drawer
enum DrawerTabBarOption: String {
    case stickers
    
    var description: String {
        switch self {
        case .stickers:
            return NSLocalizedString("Stickers", comment: "Stickers tab text in media drawer")
        }
    }
}
