//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Creates Filter instances from filter types
struct FilterFactory {

    /// Creates a filter for the provided type and glContext
    /// - Parameter type: FilterType to create
    /// - Parameter glContext: The EAGLContext to bind this filter to.
    static func createFilter(type: FilterType, glContext: EAGLContext?, transform: Transformation?) -> FilterProtocol {
        var newFilter: FilterProtocol
        switch type {
        case .passthrough: fallthrough
        case .off:
            newFilter = Filter(glContext: glContext, transform: transform)
        case .emInterference:
            newFilter = EMInterferenceFilter(glContext: glContext, transform: transform)
        case .film:
            newFilter = FilmFilter(glContext: glContext, transform: transform)
        case .lego:
            newFilter = LegoFilter(glContext: glContext, transform: transform)
        case .mirrorTwo:
            newFilter = MirrorTwoFilter(glContext: glContext, transform: transform)
        case .mirrorFour:
            newFilter = MirrorFourFilter(glContext: glContext, transform: transform)
        case .plasma:
            newFilter = PlasmaFilter(glContext: glContext, transform: transform)
        case .rave:
            newFilter = RaveFilter(glContext: glContext, transform: transform)
        case .rgb:
            newFilter = RGBFilter(glContext: glContext, transform: transform)
        case .chroma:
            newFilter = ChromaFilter(glContext: glContext, transform: transform)
        case .grayscale:
            newFilter = GrayscaleFilter(glContext: glContext, transform: transform)
        case .lightLeaks:
            newFilter = LightLeaksFilter(glContext: glContext, transform: transform)
        case .wavePool:
            newFilter = WavePoolFilter(glContext: glContext, transform: transform)
        case .manga:
            newFilter = MangaFilter(glContext: glContext, transform: transform)
        case .toon:
            newFilter = ToonFilter(glContext: glContext, transform: transform)
        }
        return newFilter
    }

    /// Creates a filter for the provided type, glContext, and overlays
    /// - Parameter type: FilterType to create
    /// - Parameter glContext: The EAGLContext to bind this filter to.
    /// - Parameter overlays: Array of CVPixelBuffer instances to overlay.
    static func createFilter(type: FilterType, glContext: EAGLContext?, overlays: [CVPixelBuffer], transform: Transformation?) -> FilterProtocol {
        guard overlays.count > 0 else {
            return FilterFactory.createFilter(type: type, glContext: glContext, transform: transform)
        }
        if type == .passthrough || type == .off {
            if overlays.count == 1, let overlay = overlays.first {
                return AlphaBlendFilter(glContext: glContext, pixelBuffer: overlay)
            }
            else {
                return GroupFilter(filters: overlays.compactMap{ AlphaBlendFilter(glContext: glContext, pixelBuffer: $0) })
            }
        }
        else {
            return GroupFilter(filters: [FilterFactory.createFilter(type: type, glContext: glContext, transform: transform)] + overlays.compactMap{ AlphaBlendFilter(glContext: glContext, pixelBuffer: $0) })
        }
    }
}
