//
//  PlaybackControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 29/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class PlaybackControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newViewController() -> PlaybackController {
        let controller = PlaybackController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: PlaybackView.height)
        controller.view.setNeedsDisplay()
        controller.viewDidLayoutSubviews()
        return controller
    }
    
    func testPlaybackControllerView() {
        let controller = newViewController()
        FBSnapshotVerifyView(controller.view)
    }
}
