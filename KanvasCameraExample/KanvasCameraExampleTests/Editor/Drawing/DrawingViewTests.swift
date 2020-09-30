//
//  DrawingViewTests.swift
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

final class DrawingViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> DrawingView {
        let view = DrawingView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.showConfirmButton(true)
        FBSnapshotVerifyView(view)
    }
    
    // Cannot test DrawingCanvas since touchesBegan cannot be called programmatically
    func testDrawingCanvas() {
        let view = newView()
        view.showConfirmButton(true)
        let drawingCanvas = DrawingCanvas()
        drawingCanvas.backgroundColor = .blue
        drawingCanvas.add(into: view)
        FBSnapshotVerifyView(view)
    }
}
