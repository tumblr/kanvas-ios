//
//  SpeedControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 22/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class SpeedControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newViewController() -> SpeedController {
        let controller = SpeedController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: SpeedView.height)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testSpeedControllerView() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.showView(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
}
