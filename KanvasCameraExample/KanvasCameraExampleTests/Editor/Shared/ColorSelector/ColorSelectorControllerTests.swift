//
//  ColorSelectorControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 08/10/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ColorSelectorControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> ColorSelectorController {
        let controller = ColorSelectorController()
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testColorSelectorControllerView() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.show(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
}
