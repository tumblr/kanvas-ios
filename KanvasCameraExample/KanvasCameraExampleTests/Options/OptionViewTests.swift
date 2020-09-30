//
// Created by Tony Cheng on 8/21/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class OptionViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func testNewButton() {
        if let image = KanvasCameraImages.flashOffImage {
            let button = OptionView(image: image)
            button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            FBSnapshotVerifyView(button)
        }
        else {
            XCTFail("Bundle image not found")
        }
    }

    func testTouchOutsideOfButton() {
        guard let image = KanvasCameraImages.flashOffImage else {
            XCTFail("Bundle image not found")
            return
        }

        let button = OptionView(image: image)
        button.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        view.addSubview(button)
        let touchPoint = CGPoint(x: 5, y: 5)
        let touched = button.point(inside: touchPoint, with: nil)
        XCTAssertTrue(touched, "Button did not receive touch")
    }
}
