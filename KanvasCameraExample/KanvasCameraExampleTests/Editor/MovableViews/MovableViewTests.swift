//
//  MovableViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 08/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class MovableViewTests: XCTestCase {
    
    func testHitAreaOffsetForBigView() {
        let imageView = StylableImageView(id: "id", image: KanvasCameraImages.gradientImage)
        let movableView = MovableView(view: imageView, transformations: ViewTransformations())
        movableView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        let offset = movableView.calculateHitAreaOffset()
        XCTAssertEqual(offset.height, 0)
        XCTAssertEqual(offset.width, 0)
    }
    
    func testHitAreaOffsetForSmallView() {
        let imageView = StylableImageView(id: "id", image: KanvasCameraImages.gradientImage)
        let movableView = MovableView(view: imageView, transformations: ViewTransformations())
        movableView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        let offset = movableView.calculateHitAreaOffset()
        XCTAssertEqual(offset.height, 40)
        XCTAssertEqual(offset.width, 40)
    }
}
