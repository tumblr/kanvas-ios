//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import MetalKit

// This is a workaround to load metal shaders from Kanvas bundle.
// 1. Read .metal files from Kanvas.bundle/MetalShaders/ directory
// 2. Concatinate all source files as a string then compile it at runtime by using MTLDevice::makeLibrary(source:options:)
extension MTLDevice {
    func makeKanvasDefaultLibrary() -> MTLLibrary? {
        #if SWIFT_PACKAGE
            guard
                let bundle = KanvasStrings.bundle(for: CameraSettings.self),
                let shadersURL = bundle.url(forResource: "shaders", withExtension: "metal"),
                let source = try? String(contentsOf: shadersURL, encoding: .utf8)
            else {
                return nil
            }
        
        #else
            guard
                let bundle = KanvasStrings.bundle(for: CameraSettings.self),
                let shaderPath = bundle.resourcePath?.appending("/MetalShaders").appending("/shaders.metal"),
                let source = try? String(contentsOfFile: shaderPath, encoding: .utf8)
            else {
                return nil
            }
        #endif

        
        do {
            let library = try makeLibrary(source: source, options: nil)
            return library
        }
        catch {
            print("\(error)")
            return nil
        }
    }
}
