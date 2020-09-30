//
//  ColorCollectionControllerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 02/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ColorCollectionControllerTests: FBSnapshotTestCase {
    
    var colors: [UIColor] = []
    
    override func setUp() {
        super.setUp()
        
        colors = [
            .tumblrBrightBlue,
            .tumblrBrightRed,
            .tumblrBrightOrange
        ]
        
        self.recordMode = false
    }
    
    func newViewController() -> ColorCollectionController {
        let controller = ColorCollectionController()
        controller.view.frame = CGRect(x: 0, y: 0,
                                       width: ColorCollectionCell.width * CGFloat(colors.count),
                                       height: ColorCollectionCell.height)
        controller.addColors(colors)
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
