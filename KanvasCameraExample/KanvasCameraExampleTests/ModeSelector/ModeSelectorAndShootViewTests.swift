//
// Created by Tony Cheng on 8/21/18.
// Copyright (c) 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ModeSelectorAndShootViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> ModeSelectorAndShootView {
        let view = ModeSelectorAndShootView(settings: CameraSettings())
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }

    func testPhotoMode() {
        let view = newView()
        view.setUpMode(.photo)
        FBSnapshotVerifyView(view)
    }

    func testGifMode() {
        let view = newView()
        view.setUpMode(.loop)
        FBSnapshotVerifyView(view)
    }

    func testStopMotionMode() {
        let view = newView()
        view.setUpMode(.stopMotion)
        FBSnapshotVerifyView(view)
    }

    func testShowModeButton() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.showModeButton(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testHideModeButton() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.showModeButton(false)
        UIImageView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

}
