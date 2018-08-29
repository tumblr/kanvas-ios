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

final class ShootButtonViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newShootButtonView() -> ShootButtonView {
        let shootButton = ShootButtonView(baseColor: .white, activeColor: .red)
        return shootButton
    }
    
    func testPhotoMode() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.configureFor(trigger: .tap, image: KanvasCameraImages.PhotoModeImage, timeLimit: KanvasCameraTimes.StopMotionFrameTimeInterval)
        FBSnapshotVerifyView(shootButton)
        UIView.setAnimationsEnabled(true)
    }

    func testGifMode() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.configureFor(trigger: .tap, image: KanvasCameraImages.GifModeImage, timeLimit: KanvasCameraTimes.GifRecordingTime)
        FBSnapshotVerifyView(shootButton)
        UIView.setAnimationsEnabled(true)
    }

    func testStopMotionMode() {
        let shootButton = newShootButtonView()
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shootButton.add(into: uiView)
        UIView.setAnimationsEnabled(false)
        shootButton.configureFor(trigger: .tapAndHold, image: KanvasCameraImages.StopMotionModeImage, timeLimit: KanvasCameraTimes.VideoRecordingTime)
        FBSnapshotVerifyView(shootButton)
        UIView.setAnimationsEnabled(true)
    }

}
