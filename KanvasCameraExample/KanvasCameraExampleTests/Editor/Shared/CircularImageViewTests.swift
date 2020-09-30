//
//  CircularImageViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 02/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class CircularImageViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCircularImageView() -> CircularImageView {
        let imageView = CircularImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: CircularImageView.size, height: CircularImageView.size)
        imageView.backgroundColor = .tumblrBrightBlue
        return imageView
    }
    
    func testViewSetup() {
        let imageView = newCircularImageView()
        FBSnapshotVerifyView(imageView)
    }
    
}
