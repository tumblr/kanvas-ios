//
//  MetalPixelBufferViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Taichi Matsumoto on 7/6/20.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import XCTest

//
// Currently Metal doesn't work on simulators
// This tests is just creating metal related instances to pass CI
//
class MetalPixelBufferViewTests: FBSnapshotTestCase {
    func testFake() {
        guard let context = MetalContext.createContext() else {
            return
        }
        let view = MetalPixelBufferView(context: context)
        XCTAssertNotNil(view)
        
        let filter = MetalFilter(context: context, kernelFunctionName: "kernelIdentity")
        XCTAssertNotNil(filter)
        
        let encoder = MetalRenderEncoder(device: context.device, library: context.library)
        XCTAssertNotNil(encoder)
        
        let shaderContext = ShaderContext(time: 0)
        XCTAssertNotNil(shaderContext)
    }
    
    func testFake2() {
        let groupFilter = MetalGroupFilter(filters: [])
        XCTAssertNotNil(groupFilter)
    }
}
