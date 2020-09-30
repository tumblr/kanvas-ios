//
//  MediaDrawerControllerTests.swift
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

final class MediaDrawerControllerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newViewController() -> MediaDrawerController {
        let controller = MediaDrawerController(stickerProvider: StickerProviderStub())
        controller.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        controller.view.setNeedsDisplay()
        return controller
    }
    
    func testMediaDrawerControllerView() {
        let controller = newViewController()
        FBSnapshotVerifyView(controller.view)
    }
}
