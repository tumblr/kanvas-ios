//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import XCTest
import CoreMedia

class GLRendererDelegateStub: GLRendererDelegate {
    var calledRendererReadyForDisplay = false
    var calledRendererFilteredPixelBufferReady = false
    var calledRendererRanOutOfBuffers = false

    func rendererReadyForDisplay(pixelBuffer: CVPixelBuffer) {
        calledRendererReadyForDisplay = true
    }

    func rendererFilteredPixelBufferReady(pixelBuffer: CVPixelBuffer, presentationTime: CMTime) {
        calledRendererFilteredPixelBufferReady = true
    }

    func rendererRanOutOfBuffers() {
        calledRendererRanOutOfBuffers = true
    }
}

class GLRendererTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let delegate = GLRendererDelegateStub()
        let _ = GLRenderer(delegate: delegate)
    }

}
