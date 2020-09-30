//
//  ModeButtonViewTests.swift
//  KanvasEditorSDKTests
//
//  Created by Tony Cheng on 8/17/18.
//  Copyright © 2018 Kanvas Labs Inc. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import UIKit
import XCTest

final class ModeButtonViewTests: FBSnapshotTestCase {
        
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newModeButton() -> ModeButtonView {
        let modeButton = ModeButtonView()
        return modeButton
    }
    
    func testPhotoMode() {
        let modeButton = newModeButton()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        modeButton.setTitle(KanvasCameraStrings.name(for: .photo))
        FBSnapshotVerifyView(modeButton)
        UIView.setAnimationsEnabled(true)
    }
    
    func testGifMode() {
        let modeButton = newModeButton()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        modeButton.setTitle(KanvasCameraStrings.name(for: .loop))
        FBSnapshotVerifyView(modeButton)
        UIView.setAnimationsEnabled(true)
    }

    func testStopMotionMode() {
        let modeButton = newModeButton()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        modeButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        modeButton.setTitle(KanvasCameraStrings.name(for: .stopMotion))
        FBSnapshotVerifyView(modeButton)
        UIView.setAnimationsEnabled(true)
    }
}
