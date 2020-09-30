//
//  EditorFilterCollectionControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 21/05/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class EditorFilterCollectionControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> EditorFilterCollectionController {
        let controller = EditorFilterCollectionController(settings: CameraSettings())
        controller.view.frame = CGRect(x: 0, y: 0, width: 600, height: 600)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testCollectionControllerView() {
        let controller = newViewController()
        UIView.setAnimationsEnabled(false)
        controller.showView(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(controller.view)
    }
}
