//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Filter types
enum FilterType: Int, CaseIterable {
    case passthrough = 0
    case film
    case plasma
    case emInterference
    case lego
    case rgb
    case rave
    case chroma
    case mirrorTwo
    case mirrorFour
    case grayscale
    case lightLeaks
    case wavePool
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
            return "EM-Interference (Glitch)"
        case .film:
            return "Film/Grainy"
        case .mirrorTwo:
            return "Mirror"
        case .rave:
            return "Rave"
        case .lego:
            return "Lego"
        case .rgb:
            return "RGB"
        case .chroma:
            return "Chroma"
        case .mirrorFour:
            return "Mirror 4"
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
