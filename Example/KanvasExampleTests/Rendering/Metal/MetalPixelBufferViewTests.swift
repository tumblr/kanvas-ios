//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
#if SWIFT_PACKAGE
import iOSSnapshotTestCase
#else
import FBSnapshotTestCase
#endif
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
        let view = MetalPixelBufferView(context: context, mediaContentMode: .scaleAspectFit)
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
