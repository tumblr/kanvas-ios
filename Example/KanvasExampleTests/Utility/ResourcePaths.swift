//
//  File.swift
//  
//
//  Created by Adriana Elizondo on 03/04/24.
//

import Foundation

public struct ResourcePaths {
    static var sampleVideoURL: URL? {
#if SWIFT_PACKAGE
        return Bundle.module.url(forResource: "sample", withExtension: "mp4")
#else
        return Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4")
#endif
    }
    
    static var sampleImagePath: String? {
#if SWIFT_PACKAGE
        return Bundle.module.path(forResource: "sample", ofType: "png")
#else
        return Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png")
#endif
    }
}
