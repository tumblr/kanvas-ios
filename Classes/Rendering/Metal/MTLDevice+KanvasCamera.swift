//
//  MTLDevice+KanvasCamera.swift
//  KanvasCamera
//
//  Created by Taichi Matsumoto on 7/4/20.
//

import MetalKit

// This is a workaround to load metal shaders from KanvasCamera bundle.
// 1. Read .metal files from KanvasCamera.bundle/MetalShaders/ directory
// 2. Concatinate all source files as a string then compile it at runtime by using MTLDevice::makeLibrary(source:options:)
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
            if filename.hasSuffix("metal") {
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
            print("\(error)")
            return nil
        }
    }
}
