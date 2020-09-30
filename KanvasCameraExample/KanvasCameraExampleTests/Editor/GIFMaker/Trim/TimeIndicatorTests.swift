//
//  TimeIndicatorTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 03/06/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class TimeIndicatorTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newView() -> TimeIndicator {
        let view = TimeIndicator()
        view.frame = CGRect(x: 0, y: 0, width: TimeIndicator.width, height: TimeIndicator.height)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.text = "0:02"
        FBSnapshotVerifyView(view)
    }
    
}
