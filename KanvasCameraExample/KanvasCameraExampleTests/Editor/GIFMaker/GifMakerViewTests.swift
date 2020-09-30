//
//  GifMakerViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 07/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class GifMakerViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> GifMakerView {
        let view = GifMakerView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.showConfirmButton(true)
        FBSnapshotVerifyView(view)
    }
    
    func testRevertButton() {
        let view = newView()
        view.toggleRevertButton(true)
        FBSnapshotVerifyView(view)
    }
    
}
