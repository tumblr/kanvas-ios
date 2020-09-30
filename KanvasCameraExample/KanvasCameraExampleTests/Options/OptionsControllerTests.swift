//
// Created by Tony Cheng on 8/21/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class OptionsControllerTests: FBSnapshotTestCase {

    var animationCalled = false
    var completionCalled = false

    let AnimationDuration: TimeInterval = 0.2

    override func setUp() {
        super.setUp()

        self.recordMode = false
        animationCalled = false
    }

    func getOptions() -> [[Option<String>]] {
        let image = KanvasCameraImages.flashOnImage
        return [[Option(option: "Option 1.1", image: image, type: .twoOptionsImages(alternateOption: "Option 1.2", alternateImage: image)),
                Option(option: "Option 2", image: image, type: .twoOptionsAnimation(animation: { [weak self] _ in self?.animationCalled = true },
                                                                                    duration: AnimationDuration,
                                                                                    completion: nil))]]
    }

    func newViewController(options: [[Option<String>]]) -> OptionsController<OptionsControllerDelegateStub> {
        let viewController = OptionsController<OptionsControllerDelegateStub>(options: options, spacing: 0, settings: CameraSettings())
        viewController.delegate = newDelegateStub()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
        return viewController
    }

    func newDelegateStub() -> OptionsControllerDelegateStub {
        let stub = OptionsControllerDelegateStub()
        return stub
    }

    func testOptionTwoImagesTapped() {
        let options = getOptions()
        let viewController = newViewController(options: options)
        UIView.setAnimationsEnabled(false)
        viewController.optionWasTapped(section: 0, optionIndex: 0)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
        // Test that the option was correctly changed
        XCTAssertEqual(options[0][0].option, "Option 1.2")
        if case let .twoOptionsImages(alternateOption: otherOption, alternateImage: _) = options[0][0].type {
            XCTAssertEqual(otherOption, "Option 1.1")
        }
        else {
            XCTFail()
        }
    }

    func testOptionTwoAnimationTapped() {
        let options = getOptions()
        let viewController = newViewController(options: options)
        UIView.setAnimationsEnabled(false)
        viewController.optionWasTapped(section: 0, optionIndex: 1)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(viewController.view)
        // Test that the animation was made
        RunLoop.main.run(until: Date())
        XCTAssert(animationCalled, "Animation not called")
        // completion test would run async, should not test
        // Test option was not mutated
        XCTAssertEqual(options[0][1].option, "Option 2")
    }

}

final class OptionsControllerDelegateStub: OptionsControllerDelegate {
    func optionSelected(_ item: String) {
        XCTAssert(item == "Option 1.2" || item == "Option 2", "The new selected option is not the correct one")
    }
}
