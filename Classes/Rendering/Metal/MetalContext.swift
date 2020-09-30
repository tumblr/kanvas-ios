//
//  MetalContext.swift
//  KanvasCamera
//
//  Created by Taichi Matsumoto on 7/1/20.
//

import Metal

final class MetalContext {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let textureCache: CVMetalTextureCache
    let library: MTLLibrary
    
    init(device: MTLDevice, commandQueue: MTLCommandQueue, textureCache: CVMetalTextureCache, library: MTLLibrary) {
        self.device = device
        self.commandQueue = commandQueue
        self.textureCache = textureCache
        self.library = library
    }
    
    static public func createContext() -> MetalContext? {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let library = device.makeKanvasDefaultLibrary(),
            let commandQueue = device.makeCommandQueue()
        else {
            return nil
        }
        var textureCache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        guard let unwrappedTextureCache = textureCache else {
            return nil
        }
        
        return MetalContext(device: device,
                            commandQueue: commandQueue,
                            textureCache: unwrappedTextureCache,
                            library: library)

    }
}
