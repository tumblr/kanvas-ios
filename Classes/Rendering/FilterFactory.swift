//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

enum FilterPlatform {
    case openGL
    case metal
}

/// Creates Filter instances from filter types
struct FilterFactory {
    private let glContext: EAGLContext?
    private let metalContext: MetalContext?
    private let filterPlatform: FilterPlatform
    init(glContext: EAGLContext?, metalContext: MetalContext?, filterPlatform: FilterPlatform) {
        self.glContext = glContext
        self.metalContext = metalContext
        self.filterPlatform = filterPlatform
    }

    /// Creates a filter for the provided type and glContext
    /// - Parameter type: FilterType to create
    /// - Parameter glContext: The EAGLContext to bind this filter to.
    func createFilter(type: FilterType) -> FilterProtocol {
        switch filterPlatform {
        case .openGL:
            return createOpenGLFilter(type: type, glContext: glContext)
        case .metal:
            return createMetalFilter(type: type, metalContext: metalContext)
        }
    }
    
    private func createOpenGLFilter(type: FilterType, glContext: EAGLContext?) -> FilterProtocol {
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
    
    private func createMetalFilter(type: FilterType, metalContext: MetalContext?) -> FilterProtocol {
        switch type {
        case .emInterference:
            return MetalFilter(context: metalContext, kernelFunctionName: "em_interference")
        case .film:
            return MetalFilter(context: metalContext, kernelFunctionName: "film")
        case .lego:
            return MetalFilter(context: metalContext, kernelFunctionName: "lego")
        case .mirrorTwo:
            return MetalFilter(context: metalContext, kernelFunctionName: "mirror2")
        case .mirrorFour:
            return MetalFilter(context: metalContext, kernelFunctionName: "mirror4")
        case .plasma:
            return MetalFilter(context: metalContext, kernelFunctionName: "plasma")
        case .rave:
            return MetalFilter(context: metalContext, kernelFunctionName: "rave")
        case .rgb:
            return MetalFilter(context: metalContext, kernelFunctionName: "rgb")
        case .chroma:
            return MetalFilter(context: metalContext, kernelFunctionName: "chroma")
        case .grayscale:
            return MetalFilter(context: metalContext, kernelFunctionName: "grayscale")
        case .lightLeaks:
            return MetalFilter(context: metalContext, kernelFunctionName: "lightLeaks")
        case .wavePool:
            return MetalFilter(context: metalContext, kernelFunctionName: "wavepool")
        case .manga:
            return MetalFilter(context: metalContext, kernelFunctionName: "manga")
        case .toon:
            return MetalFilter(context: metalContext, kernelFunctionName: "toon")
        default:
            return MetalFilter(context: metalContext, kernelFunctionName: "kernelIdentity")
        }
    }

    /// Creates a filter for the provided type, glContext, and overlays
    /// - Parameter type: FilterType to create
    /// - Parameter glContext: The EAGLContext to bind this filter to.
    /// - Parameter overlays: Array of CVPixelBuffer instances to overlay.
    func createFilter(type: FilterType, overlays: [CVPixelBuffer]) -> FilterProtocol {
        switch filterPlatform {
        case .openGL:
            let filters = createOpenGLFilterList(type: type, overlays: overlays)
            return createOpenGLFilter(fromFilterList: filters)
        case .metal:
            return createMetalFilter(type: type, metalContext: metalContext, overlays: overlays)
        }
    }

    private func createOpenGLFilterList(type: FilterType, overlays: [CVPixelBuffer]) -> [FilterProtocol] {
        var filters: [FilterProtocol] = []

        // not sure if this is OK...
        let f = OpenGLFilter(glContext: glContext)
        filters.append(f)

        filters.append(createFilter(type: type))
        filters.append(contentsOf: overlays.compactMap{ AlphaBlendOpenGLFilter(glContext: glContext, pixelBuffer: $0) })
        return filters
    }

    private func createOpenGLFilter(fromFilterList filters: [FilterProtocol]) -> FilterProtocol {
        return filters.count > 1 ? GroupOpenGLFilter(filters: filters) : filters.first ?? OpenGLFilter(glContext: glContext)
    }
    
    private func createMetalFilter(type: FilterType, metalContext: MetalContext?, overlays: [CVPixelBuffer]) -> FilterProtocol {
        if overlays.count == 0 {
            return createMetalFilter(type: type, metalContext: metalContext)
        }
        else {
            var filters = [MetalFilter]()
            if let baseFilter = createMetalFilter(type: type, metalContext: metalContext) as? MetalFilter {
                filters.append(baseFilter)
            }
            let overlays = overlays.compactMap { MetalFilter(context: metalContext, kernelFunctionName: "alpha_blend", overlayBuffer: $0) }
            filters.append(contentsOf: overlays)
            return MetalGroupFilter(filters: filters)
        }
    }
}
