//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import Kanvas
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class OptionsStackViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func options() -> [Option<CameraOption>] {
        var options: [Option<CameraOption>] = []
        options.append(Option(option: CameraOption.flashOff, image: KanvasImages.flashOffImage, backgroundColor: .clear, type: .twoOptionsImages(alternateOption: CameraOption.flashOn, alternateImage: KanvasImages.flashOnImage, alternateBackgroundColor: .clear)))
        options.append(Option(option: CameraOption.frontCamera, image: KanvasImages.cameraPositionImage, backgroundColor: .clear, type: .twoOptionsAnimation(animation: { UIView in }, duration: 0.15, completion: nil)))
        return options
    }

    func newStackView() -> OptionsStackView<CameraOption> {
        let stackView = OptionsStackView<CameraOption>(section: 0, options: options(), interItemSpacing: 32, settings: CameraSettings())
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
