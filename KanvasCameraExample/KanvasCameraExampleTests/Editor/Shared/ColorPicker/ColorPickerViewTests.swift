//
//  ColorPickerViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 23/07/2019.
//  Copyright © 2019 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class ColorPickerViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> ColorPickerView {
        let view = ColorPickerView()
        view.frame = CGRect(x: 0, y: 0,
                            width: 120,
                            height: 40)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        FBSnapshotVerifyView(view)
    }
}
