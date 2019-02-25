//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

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

struct FilterFactory {
    
    static func createFilter(type: FilterType, glContext: EAGLContext?) -> FilterProtocol {
        var newFilter: FilterProtocol
        switch type {
        case .passthrough:
            newFilter = Filter(glContext: glContext)
        case .emInterference:
            newFilter = EMInterferenceFilter(glContext: glContext)
        case .film:
            newFilter = FilmFilter(glContext: glContext)
        case .lego:
            newFilter = LegoFilter(glContext: glContext)
        case .mirrorTwo:
            newFilter = MirrorTwoFilter(glContext: glContext)
        case .mirrorFour:
            newFilter = MirrorFourFilter(glContext: glContext)
        case .plasma:
            newFilter = PlasmaFilter(glContext: glContext)
        case .rave:
            newFilter = RaveFilter(glContext: glContext)
        case .rgb:
            newFilter = RGBFilter(glContext: glContext)
        case .chroma:
            newFilter = ChromaFilter(glContext: glContext)
        case .grayscale:
            newFilter = GrayscaleFilter(glContext: glContext)
        case .lightLeaks:
            newFilter = LightLeaksFilter(glContext: glContext)
        case .wavePool:
            newFilter = WavePoolFilter(glContext: glContext)
        case .magna:
            newFilter = MangaFilter(glContext: glContext)
        case .toon:
            newFilter = ToonFilter(glContext: glContext)
        }
        return newFilter
    }
}
