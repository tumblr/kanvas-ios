//
//  StylableTextViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 09/09/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class StylableTextViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        return view
    }
    
    func testTextViewWithText() {
        let view = newView()
        let textView = StylableTextView()
        textView.add(into: view)
        textView.text = "Example"
        textView.textAlignment = .center
        textView.font = .fairwater(fontSize: 48)
        FBSnapshotVerifyView(textView)
    }
    
    func testHitInsideShape() {
        let view = newView()
        let textView = StylableTextView()
        textView.add(into: view)
        textView.text = "Example"
        textView.textAlignment = .left
        textView.font = .fairwater(fontSize: 48)
        // Text will be at the top-left corner.
        let point = CGPoint(x: 30, y: 30)
        let wasHitInside = textView.hitInsideShape(point: point)
        XCTAssertTrue(wasHitInside, "The method should return true since the hit was done on the text.")
    }
    
    func testHitOutsideShape() {
        let view = newView()
        let textView = StylableTextView()
        textView.add(into: view)
        textView.text = "Example"
        // Text will be at the top-left corner.
        textView.textAlignment = .left
        textView.font = .fairwater(fontSize: 48)
        let point = CGPoint(x: 320, y: 320)
        let wasHitInside = textView.hitInsideShape(point: point)
        XCTAssertFalse(wasHitInside, "The method should return false since the hit was done in an empty area of the image.")
    }
}
