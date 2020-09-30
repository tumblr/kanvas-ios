//
//  ConicalGradientLayerTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 05/02/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ConicalGradientLayerTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func testTumblrColorsGradient() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let gradient = ConicalGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [.tumblrBrightRed,
                           .tumblrBrightPink,
                           .tumblrBrightOrange,
                           .tumblrBrightYellow,
                           .tumblrBrightGreen,
                           .tumblrBrightBlue,
                           .tumblrBrightPurple,
                           .tumblrBrightRed]
        view.layer.addSublayer(gradient)
        FBSnapshotVerifyView(view)
    }
}
