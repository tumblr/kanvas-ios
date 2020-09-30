//
//  DiscreteSliderTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 27/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class DiscreteSliderTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newSlider() -> DiscreteSlider {
        let items: [Float] = [0.5, 1, 1.5, 2, 3, 4]
        let initialIndex: Int = 1
        let slider = DiscreteSlider(items: items, initialIndex: initialIndex)
        slider.view.frame = CGRect(x: 0, y: 0, width: 320, height: 36)
        slider.view.setNeedsDisplay()
        return slider
    }
    
    func testSliderView() {
        let slider = newSlider()
        FBSnapshotVerifyView(slider.view)
    }
}
