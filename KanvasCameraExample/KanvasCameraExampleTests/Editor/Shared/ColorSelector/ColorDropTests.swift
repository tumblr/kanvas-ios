//
//  ColorDropTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 12/08/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ColorDropTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newColorDrop() -> ColorDrop {
        let colorDrop = ColorDrop()
        colorDrop.frame = CGRect(x: 0, y: 0, width: ColorDrop.defaultWidth, height: ColorDrop.defaultHeight)
        colorDrop.innerColor = .tumblrBrightBlue
        return colorDrop
    }
    
    func testViewSetup() {
        let imageView = newColorDrop()
        FBSnapshotVerifyView(imageView)
    }
    
}
