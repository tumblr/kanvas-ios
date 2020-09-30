//
//  OptionTests.swift
//  KanvasCameraExampleTests
//
//  Created by Tony Cheng on 8/29/18.
//  Copyright © 2018 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class OptionTests: XCTestCase {
    
    func testFlashTopOption() {
        let option = Option(option: CameraOption.flashOff, image: KanvasCameraImages.flashOffImage, type: .twoOptionsImages(alternateOption: CameraOption.flashOn, alternateImage: KanvasCameraImages.flashOnImage))
        XCTAssert(option.image != nil && option.image == KanvasCameraImages.flashOffImage, "The option image does not match the expected image")
        XCTAssert(option.option == .flashOff, "The option does not match flash on option")
        
        switch option.type {
            case .twoOptionsImages(alternateOption: let alternateItem, alternateImage: let image):
                XCTAssert(alternateItem == CameraOption.flashOn, "The alternate item did not match the expected item")
                XCTAssert(image == KanvasCameraImages.flashOnImage, "The alternate image did not match the expected image")
                break
            default:
                XCTFail("Option did not match the expected twoOptionsImages type")
        }
    }
    
}
