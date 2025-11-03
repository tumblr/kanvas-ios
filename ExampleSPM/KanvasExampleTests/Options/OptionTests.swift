//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import Foundation
import UIKit
import XCTest

final class OptionTests: XCTestCase {
    
    func testFlashTopOption() {
        let backgroundColor: UIColor = .clear
        let option = Option(option: CameraOption.flashOff, image: KanvasImages.flashOffImage, backgroundColor: backgroundColor, type: .twoOptionsImages(alternateOption: CameraOption.flashOn, alternateImage: KanvasImages.flashOnImage, alternateBackgroundColor: .clear))
        XCTAssert(option.image != nil && option.image == KanvasImages.flashOffImage, "The option image does not match the expected image")
        XCTAssert(option.option == .flashOff, "The option does not match flash on option")
        
        switch option.type {
        case .twoOptionsImages(alternateOption: let alternateItem, alternateImage: let image, alternateBackgroundColor: let color):
                XCTAssert(alternateItem == CameraOption.flashOn, "The alternate item did not match the expected item")
                XCTAssert(image == KanvasImages.flashOnImage, "The alternate image did not match the expected image")
            XCTAssert(color == backgroundColor, "The alternate color did not match the expected color")
                break
            default:
                XCTFail("Option did not match the expected twoOptionsImages type")
        }
    }
    
}
