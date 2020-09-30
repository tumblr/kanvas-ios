//
//  DiscreteSliderViewTests.swift
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

final class DiscreteSliderViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> DiscreteSliderView {
        let view = DiscreteSliderView()
        view.backgroundColor = .darkGray
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 36)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.cellWidth = view.bounds.width / 5
        view.setSelector(at: 0)
        FBSnapshotVerifyView(view)
    }
    
    func testViewSetupWithIndex() {
        let view = newView()
        view.cellWidth = view.bounds.width / 5
        view.setSelector(at: 2)
        FBSnapshotVerifyView(view)
    }
    
    func testViewSetupAtLastPosition() {
        let view = newView()
        view.cellWidth = view.bounds.width / 5
        view.setSelector(at: 4)
        FBSnapshotVerifyView(view)
    }
}
