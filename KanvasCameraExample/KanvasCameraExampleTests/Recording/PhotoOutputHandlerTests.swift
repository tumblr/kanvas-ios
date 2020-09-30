//
// Created by Tony Cheng on 8/27/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import Foundation
import XCTest

final class PhotoOutputHandlerTests: XCTestCase {

    func setupHandler() -> PhotoOutputHandler {
        let handler = PhotoOutputHandler(photoOutput: nil)
        return handler
    }

    func setupMockHandler() -> PhotoOutputHandlerMock {
        let handler = PhotoOutputHandlerMock()
        return handler
    }

    func testCompletionBlock() {
        let handler = setupHandler()
        let blockExpectation = XCTestExpectation(description: "block completed")
        handler.takePhoto(settings: AVCapturePhotoSettings()) { image in
            XCTAssert(image == nil, "Image should be nil if no photo output was passed")
            blockExpectation.fulfill()
        }
        wait(for: [blockExpectation], timeout: 5)
    }
    
    func testMockHandlerCompletion() {
        let handler = setupMockHandler()
        let completion: ((UIImage?) -> Void) = { image in }
        handler.takePhoto(settings: AVCapturePhotoSettings(), completion: completion)
        XCTAssert(handler.completionCalled, "Completion closure should have been called")
        XCTAssert(handler.completion != nil, "Completion property should have been set")
    }

}

final class PhotoOutputHandlerMock: PhotoOutputHandlerProtocol {
   
    var completion: ((UIImage?) -> Void)?
    var completionCalled = false
    
    func takePhoto(settings: AVCapturePhotoSettings, completion: @escaping (UIImage?) -> Void) {
        completionCalled = true
        self.completion = completion
    }
}
