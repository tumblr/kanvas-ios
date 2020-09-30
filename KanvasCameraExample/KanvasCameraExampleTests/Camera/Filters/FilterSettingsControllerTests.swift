//
//  FilterSettingsControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 11/02/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class FilterSettingsControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> FilterSettingsController {
        let controller = FilterSettingsController(settings: CameraSettings())
        controller.view.frame = CGRect(x: 0, y: 0, width: 600, height: FilterSettingsView.height)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testHideCollection() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.didTapVisibilityButton()
        controller.didTapVisibilityButton()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }

    func testShowCollection() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.didTapVisibilityButton()
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
}
