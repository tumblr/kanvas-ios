//
//  ColorSelectorViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 08/10/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ColorSelectorViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> ColorSelectorView {
        let view = ColorSelectorView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        UIView.setAnimationsEnabled(false)
        view.show(true)
        UIView.setAnimationsEnabled(true)
        FBSnapshotVerifyView(view)
    }
    
}
