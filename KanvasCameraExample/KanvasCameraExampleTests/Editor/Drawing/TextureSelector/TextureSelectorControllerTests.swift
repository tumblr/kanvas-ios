//
//  TextureSelectorController.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 23/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class TextureSelectorControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> TextureSelectorController {
        let controller = TextureSelectorController()
        controller.view.frame = CGRect(x: 0, y: 0,
                                       width: TextureSelectorView.selectorWidth,
                                       height: TextureSelectorView.selectorHeight)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testSelectorControllerView() {
        let controller = newViewController()
        FBSnapshotVerifyView(controller.view)
    }
}
