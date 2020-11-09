//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import UIKit
import XCTest

final class OptionTests: XCTestCase {
    
    func testFlashTopOption() {
        let option = Option(option: CameraOption.flashOff, image: KanvasCameraImages.flashOffImage, backgroundColor: .clear, type: .twoOptionsImages(alternateOption: CameraOption.flashOn, alternateImage: KanvasCameraImages.flashOnImage, alternateBackgroundColor: .clear))
        XCTAssert(option.image != nil && option.image == KanvasCameraImages.flashOffImage, "The option image does not match the expected image")
        XCTAssert(option.option == .flashOff, "The option does not match flash on option")
        
        switch option.type {
        case .twoOptionsImages(alternateOption: let alternateItem, alternateImage: let image, alternateBackgroundColor: let color):
                XCTAssert(alternateItem == CameraOption.flashOn, "The alternate item did not match the expected item")
                XCTAssert(image == KanvasCameraImages.flashOnImage, "The alternate image did not match the expected image")
                break
            default:
                XCTFail("Option did not match the expected twoOptionsImages type")
        }
    }
    
}
