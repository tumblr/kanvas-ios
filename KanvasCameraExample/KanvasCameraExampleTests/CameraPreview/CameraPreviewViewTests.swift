//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import Foundation
import AVFoundation
import UIKit
import XCTest
import FBSnapshotTestCase

final class CameraPreviewViewTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()

        self.recordMode = false
    }

    func newView() -> CameraPreviewView {
        let view = CameraPreviewView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }

    func newPlayer() -> AVPlayer? {
        return Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "mp4").map { AVPlayer(url: $0) }
    }

    func newImage() -> UIImage? {
        return Bundle(for: type(of: self)).path(forResource: "sample", ofType: "png").flatMap { UIImage(contentsOfFile: $0) }
    }

    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }

    func testSetFirstPlayer() {
        let view = newView()
        let player = newPlayer()
        view.setFirstPlayer(player: player)
        FBSnapshotVerifyView(view)
    }

    func testSetSecondPlayer() {
        let view = newView()
        let player = newPlayer()
        view.setSecondPlayer(player: player)
        FBSnapshotVerifyView(view)
    }

    func testSetImage() {
        let view = newView()
        if let image = newImage() {
            UIView.setAnimationsEnabled(false)
            view.setImage(image: image)
            UIView.setAnimationsEnabled(true)
            FBSnapshotVerifyView(view)
        }
    }

    func testShowFirstPlayer() {
        let view = newView()
        let player = newPlayer()
        view.setFirstPlayer(player: player)
        UIView.setAnimationsEnabled(false)
        view.showFirstPlayer()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testShowSecondPlayer() {
        let view = newView()
        let player = newPlayer()
        view.setSecondPlayer(player: player)
        UIView.setAnimationsEnabled(false)
        view.showSecondPlayer()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testShowSecondPlayerAfterFirstPlayer() {
        let view = newView()
        let player1 = newPlayer()
        let player2 = newPlayer()
        view.setFirstPlayer(player: player1)
        view.setSecondPlayer(player: player2)
        UIView.setAnimationsEnabled(false)
        view.showFirstPlayer()
        view.showSecondPlayer()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testShowFirstPlayerAfterSecondPlayer() {
        let view = newView()
        let player1 = newPlayer()
        let player2 = newPlayer()
        view.setFirstPlayer(player: player1)
        view.setSecondPlayer(player: player2)
        UIView.setAnimationsEnabled(false)
        view.showSecondPlayer()
        view.showFirstPlayer()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }

    func testShowImageAfterFirstPlayer() {
        let view = newView()
        let player = newPlayer()
        view.setFirstPlayer(player: player)
        if let image = newImage() {
            UIView.setAnimationsEnabled(false)
            view.showFirstPlayer()
            view.setImage(image: image)
            UIView.setAnimationsEnabled(true)
            FBSnapshotVerifyView(view)
        }
    }

    func testShowFirstPlayerAfterImage() {
        let view = newView()
        let player = newPlayer()
        view.setFirstPlayer(player: player)
        if let image = newImage() {
            UIView.setAnimationsEnabled(false)
            view.setImage(image: image)
            view.showFirstPlayer()
            UIView.setAnimationsEnabled(true)
            FBSnapshotVerifyView(view)
        }
    }

    func testShowSecondPlayerAfterImage() {
        let view = newView()
        let player = newPlayer()
        view.setSecondPlayer(player: player)
        if let image = newImage() {
            UIView.setAnimationsEnabled(false)
            view.setImage(image: image)
            view.showSecondPlayer()
            UIView.setAnimationsEnabled(true)
            FBSnapshotVerifyView(view)
        }
    }

}
