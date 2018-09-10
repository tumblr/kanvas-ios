//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
import UIKit
@testable import KanvasCamera

final class OptionTests: XCTestCase {
    
    func testFlashTopOption() {
        let option = Option(option: CameraDeviceOption.flashOff, image: KanvasCameraImages.FlashOffImage, type: .twoOptionsImages(alternateOption: CameraDeviceOption.flashOn, alternateImage: KanvasCameraImages.FlashOnImage))
        XCTAssert(option.image != nil && option.image == KanvasCameraImages.FlashOffImage, "The option image does not match the expected image")
        XCTAssert(option.option == .flashOff, "The option does not match flash on option")
        
        switch option.type {
            case .twoOptionsImages(alternateOption: let alternateItem, alternateImage: let image):
                XCTAssert(alternateItem == CameraDeviceOption.flashOn, "The alternate item did not match the expected item")
                XCTAssert(image == KanvasCameraImages.FlashOnImage, "The alternate image did not match the expected image")
                break
            default:
                XCTFail("Option did not match the expected twoOptionsImages type")
        }
    }
    
}
