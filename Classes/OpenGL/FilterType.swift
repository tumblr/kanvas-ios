//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Filter types
enum FilterType: Int, CaseIterable {
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
    case magna
    case toon

    /// Debug names for the filters.
    func name() -> String {
        switch self {
        case .passthrough:
            return "None"
        case .plasma:
            return "Plasma"
        case .emInterference:
            return "EM-Interference"
        case .film:
            return "Noise"
        case .mirrorTwo:
            return "Twop Mirror"
        case .rave:
            return "Rave"
        case .lego:
            return "Lego"
        case .rgb:
            return "RGB"
        case .chroma:
            return "Chroma"
        case .mirrorFour:
            return "Four Mirror"
        case .grayscale:
            return "Black & White"
        case .lightLeaks:
            return "Rainbow"
        case .wavePool:
            return "Water"
        case .magna:
            return "Magna"
        case .toon:
            return "Toon"
        }
    }
}
