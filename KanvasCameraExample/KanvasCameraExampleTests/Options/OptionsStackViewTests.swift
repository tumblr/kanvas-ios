//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest
import AVFoundation
import UIKit
import FBSnapshotTestCase
@testable import KanvasCamera

final class OptionsStackViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func options() -> [Option<TopOption>] {
        var options: [Option<TopOption>] = []
        options.append(Option(option: TopOption.flashOff, image: KanvasCameraImages.FlashOffImage, type: .twoOptionsImages(alternateOption: TopOption.flashOn, alternateImage: KanvasCameraImages.FlashOnImage)))
        options.append(Option(option: TopOption.frontCamera, image: KanvasCameraImages.CameraPositionImage, type: .twoOptionsAnimation(animation: { UIView in }, duration: 0.15, completion: nil)))
        return options
    }

    func newStackView() -> OptionsStackView<TopOption> {
        let stackView = OptionsStackView<TopOption>(options: options(), interItemSpacing: 32)
        stackView.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
        return stackView
    }

    func testChangeOptions() {
        let stackView = newStackView()
        let options = self.options()
        stackView.changeOptions(to: options)
        FBSnapshotVerifyView(stackView)
    }
}
