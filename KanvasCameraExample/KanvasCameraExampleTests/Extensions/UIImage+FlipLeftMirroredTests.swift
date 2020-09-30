//
//  UIImage+FlipLeftMirroredTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 28/12/2018.
//  Copyright © 2018 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class FlipLeftMirroredTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newView() -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }
    
    func testFlipImageHorizontally() {
        let view = newView()
        let imageView = UIImageView(image: KanvasCameraImages.imagePreviewOnImage?.flipLeftMirrored())
        imageView.add(into: view)
        FBSnapshotVerifyView(view)
    }
}
