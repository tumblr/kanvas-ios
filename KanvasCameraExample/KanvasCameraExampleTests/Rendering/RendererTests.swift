//
//  RendererTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 2/20/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import XCTest
import CoreMedia

class RendererDelegateStub: RendererDelegate {
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

class RendererTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let delegate = RendererDelegateStub()
        let renderer = Renderer()
        renderer.delegate = delegate
    }

}
