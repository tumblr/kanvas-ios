//
//  SpeedViewTests.swift
//  KanvasCameraExampleTests
//
//  Created by Gabriel Mazzei on 22/05/2020.
//  Copyright © 2020 Tumblr. All rights reserved.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class SpeedViewTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    private func newView() -> SpeedView {
        let view = SpeedView()
        view.frame = CGRect(x: 0, y: 0, width: 320, height: SpeedView.height)
        return view
    }
    
    func testViewSetup() {
        let view = newView()
        view.setLabelText("1x")
        FBSnapshotVerifyView(view)
    }
}
