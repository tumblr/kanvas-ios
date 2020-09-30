//
//  DrawerTabBarControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 18/11/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class DrawerTabBarControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> DrawerTabBarController {
        let controller = DrawerTabBarController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: DrawerTabBarView.height)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testDrawerTabBarControllerView() {
        let controller = newViewController()
        FBSnapshotVerifyView(controller.view)
    }
}
