//
//  PlaybackOption.swift
//  KanvasCamera
//
//  Created by Gabriel Mazzei on 29/05/2020.
//

import Foundation

/// A representation of a playback option to be presented in PlaybackController
enum PlaybackOption: String {
    case loop
    case rebound
    case reverse
    
    /// Localized string for the option.
    var description: String {
        switch self {
        case .loop:
            return NSLocalizedString("GIFLoop", comment: "Loop playback mode")
        case .rebound:
            return NSLocalizedString("GIFRebound", comment: "Rebound playback mode")
        case .reverse:
            return NSLocalizedString("GIFReverseLoop", comment: "Reverse playback mode")
        }
    }
}
