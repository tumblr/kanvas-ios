//
//  GLPixelBufferViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Jimmy Schementi on 2/20/19.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import XCTest

class GLPixelBufferViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func testPixelBufferView() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let view = GLPixelBufferView(delegate: nil)
        view.frame = rect
        if let image = Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap({ UIImage(contentsOfFile: $0) }) {
            if let pixelBuffer = image.pixelBuffer() {
                view.displayPixelBuffer(pixelBuffer)
            }
            else {
                XCTAssert(false, "Failed to generate pixel buffer")
            }
            _ = view
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 2.0))
            FBSnapshotVerifyView(view)
        }
        else {
            XCTAssert(false, "Failed to load sample.png")
        }
    }

}
