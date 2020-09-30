//
//  ShootButtonViewTests.swift
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

final class ShootButtonViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newShootButtonView() -> ShootButtonView {
        let shootButton = ShootButtonView(baseColor: .white)
        return shootButton
    }
    
    func testPhotoMode() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.configureFor(trigger: .tap, image: KanvasCameraImages.photoModeImage, timeLimit: KanvasCameraTimes.stopMotionFrameTimeInterval)
        FBSnapshotVerifyView(shootButton)
        UIView.setAnimationsEnabled(true)
    }

    func testGifMode() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.configureFor(trigger: .tap, image: KanvasCameraImages.loopModeImage, timeLimit: KanvasCameraTimes.gifTapRecordingTime)
        FBSnapshotVerifyView(shootButton)
        UIView.setAnimationsEnabled(true)
    }

    func testStopMotionMode() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.configureFor(trigger: .tapOrHold(animateCircle: true), image: KanvasCameraImages.stopMotionModeImage, timeLimit: KanvasCameraTimes.videoRecordingTime)
        FBSnapshotVerifyView(shootButton)
        UIView.setAnimationsEnabled(true)
    }
    
    func testShowOpenTrash() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.openTrash()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(shootButton)
    }
    
    func testShowClosedTrash() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.closeTrash()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(shootButton)
    }
    
    func testOpenAndHideTrash() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.openTrash()
        shootButton.hideTrash()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(shootButton)
    }
    
    func testCloseAndHideTrash() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.openTrash()
        shootButton.hideTrash()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(shootButton)
    }
}
