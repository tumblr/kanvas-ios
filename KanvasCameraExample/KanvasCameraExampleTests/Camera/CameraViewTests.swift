//
//  CameraViewTests.swift
//  EditorTestTests
//
//  Created by Daniela Riesgo on 30/08/2018.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class CameraViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newView() -> CameraView {
        let view = CameraView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }

    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }

    func testUpdateUIForRecording() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.updateUI(forRecording: true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testUpdateUIForNotRecording() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.updateUI(forRecording: true)
        view.updateUI(forRecording: false)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

}
