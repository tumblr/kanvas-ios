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
    static func createFilter(type: FilterType, glContext: EAGLContext?) -> FilterProtocol {
        var newFilter: FilterProtocol
        switch type {
        case .passthrough: fallthrough
        case .off:
            newFilter = OpenGLFilter(glContext: glContext)
        case .emInterference:
            newFilter = EMInterferenceOpenGLFilter(glContext: glContext)
        case .film:
            newFilter = FilmOpenGLFilter(glContext: glContext)
        case .lego:
            newFilter = LegoOpenGLFilter(glContext: glContext)
        case .mirrorTwo:
            newFilter = MirrorTwoOpenGLFilter(glContext: glContext)
        case .mirrorFour:
            newFilter = MirrorFourOpenGLFilter(glContext: glContext)
        case .plasma:
            newFilter = PlasmaOpenGLFilter(glContext: glContext)
        case .rave:
            newFilter = RaveOpenGLFilter(glContext: glContext)
        case .rgb:
            newFilter = RGBOpenGLFilter(glContext: glContext)
        case .chroma:
            newFilter = ChromaOpenGLFilter(glContext: glContext)
        case .grayscale:
            newFilter = GrayscaleOpenGLFilter(glContext: glContext)
        case .lightLeaks:
            newFilter = LightLeaksOpenGLFilter(glContext: glContext)
        case .wavePool:
            newFilter = ImagePoolOpenGLFilter(glContext: glContext)
        case .manga:
            newFilter = MangaOpenGLFilter(glContext: glContext)
        case .toon:
            newFilter = ToonOpenGLFilter(glContext: glContext)
        }
        return newFilter
    }

    /// Creates a filter for the provided type, glContext, and overlays
    /// - Parameter type: FilterType to create
    /// - Parameter glContext: The EAGLContext to bind this filter to.
    /// - Parameter overlays: Array of CVPixelBuffer instances to overlay.
    static func createFilter(type: FilterType, glContext: EAGLContext?, overlays: [CVPixelBuffer]) -> FilterProtocol {
        let filters = createFilterList(type: type, glContext: glContext, overlays: overlays)
        return createFilter(fromFilterList: filters, glContext: glContext)
    }

    private static func createFilterList(type: FilterType, glContext: EAGLContext?, overlays: [CVPixelBuffer]) -> [FilterProtocol] {
        var filters: [FilterProtocol] = []

        // not sure if this is OK...
        let f = OpenGLFilter(glContext: glContext)
        filters.append(f)

        filters.append(createFilter(type: type, glContext: glContext))
        filters.append(contentsOf: overlays.compactMap{ AlphaBlendFilter(glContext: glContext, pixelBuffer: $0) })
        return filters
    }

    private static func createFilter(fromFilterList filters: [FilterProtocol], glContext: EAGLContext?) -> FilterProtocol {
        return filters.count > 1 ? GroupOpenGLFilter(filters: filters) : filters.first ?? OpenGLFilter(glContext: glContext)
    }
}
