//
//  SliderViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 27/01/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import AVFoundation
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class SliderViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newSliderView() -> SliderView {
        let sliderView = SliderView()
        sliderView.frame = CGRect(x: 0, y: 0, width: 34, height: 130)
        return sliderView
    }
    
    func testSliderView() {
        let sliderView = newSliderView()
        FBSnapshotVerifyView(sliderView)
    }
}
