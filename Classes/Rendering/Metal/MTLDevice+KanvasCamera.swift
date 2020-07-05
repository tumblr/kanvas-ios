//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import MetalKit

extension MTLDevice {
    func makeKanvasDefaultLibrary() -> MTLLibrary? {
        guard
            let bundlePath = KanvasCameraStrings.bundlePath(for: CameraSettings.self)
        else {
            return nil
        }

        let shaderDirectoryPath = "\(bundlePath)/MetalShaders"
        
        let enumerator = FileManager.default.enumerator(atPath: shaderDirectoryPath)
        var source = ""
        while let filename = enumerator?.nextObject() as? String {
            if filename.hasSuffix("h") || filename.hasSuffix("metal") {
                let fileURL = "\(shaderDirectoryPath)/\(filename)"
                do {
                    source += try String(contentsOfFile: fileURL, encoding: .utf8)
                }
                catch {
                    print("failed to read \(filename)")
                }
            }
        }
        
        do {
            let library = try makeLibrary(source: source, options: nil)
            return library
        }
        catch {
            return nil
        }
    }
}
