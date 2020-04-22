//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation



/// Filter types
@objc public enum FilterType: Int {
    case passthrough = 0
    case wavePool
    case plasma
    case emInterference
    case rgb
    case lego
    case chroma
    case rave
    case mirrorTwo
    case mirrorFour
    case lightLeaks
    case film
    case grayscale
    case manga
    case toon
    case off

    /// Logging key for a filter type
    /// Returns a string representing the filter type, or nil if the FilterType is "off",/
    /// which indicates that the feature is disabled.
    public func key() -> String? {
        switch self {
        case .passthrough:
            return "normal"
        case .plasma:
            return "plasma"
        case .emInterference:
            return "em_interference"
        case .film:
            return "film"
        case .mirrorTwo:
            return "mirror_2"
        case .rave:
            return "rave"
        case .lego:
            return "lego"
        case .rgb:
            return "rgb"
        case .chroma:
            return "chroma"
        case .mirrorFour:
            return "mirror_4"
        case .grayscale:
            return "grayscale"
        case .lightLeaks:
            return "light_leaks"
        case .wavePool:
            return "wave_pool"
        case .manga:
            return "manga"
        case .toon:
            return "toon"
        case .off:
            return nil
        }
    }
    
    public var filterApplied: Bool {
        return self != .off && self != .passthrough
    }
}
