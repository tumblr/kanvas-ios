//
// Created by Tony Cheng on 8/21/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
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
        options.append(Option(option: CameraOption.flashOff, image: KanvasCameraImages.flashOffImage, type: .twoOptionsImages(alternateOption: CameraOption.flashOn, alternateImage: KanvasCameraImages.flashOnImage)))
        options.append(Option(option: CameraOption.frontCamera, image: KanvasCameraImages.cameraPositionImage, type: .twoOptionsAnimation(animation: { UIView in }, duration: 0.15, completion: nil)))
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
